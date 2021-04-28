/// Cette bibliothèque définit les classes du modèle de données de l'application
/// courses3 : [Rayon], [Produit] et [VueModele].
library modele;

import 'package:courses3/backend.dart';
import 'package:flutter/foundation.dart';

import 'storage.dart';

late VueModele modele;

/// Un produit défini par son [nom] et son [rayon].
class Produit extends ChangeNotifier {
  /// Le [nom] de ce [Produit].
  String nom;

  /// Le [rayon] de ce [Produit].
  Rayon rayon;

  /// La [quantite] actuellement sélectionnée.
  int quantite;

  /// Indique si ce [Produit] a été placé dans le charriot.
  bool fait;

  /// Crée un nouveau Produit avec son [nom] et son [rayon]. Par défaut, la
  /// [quantite] est initialisée à `0` et [fait] à `false`.
  Produit(this.nom, this.rayon, [this.quantite = 0, this.fait = false]);

  /// Crée un nouveau [Produit] depuis une [map].
  factory Produit.fromMap(Map<String, dynamic> map) => Produit(
      map['nom'] as String,
      Rayon.fromMap(map['rayon'] as Map<String, dynamic>),
      map['quantite'] as int,
      map['fait'] as bool);

  /// Transforme ce [Produit] en `Map<String, dynamic>`.
  Map<String, dynamic> toMap() =>
      {'nom': nom, 'rayon': rayon.toMap(), 'quantite': quantite, 'fait': fait};

  /// Renvoie une représentation textuelle de ce [Produit].
  @override
  String toString() =>
      'Produit(nom: $nom, rayon: $rayon, quantite: $quantite, fait: $fait)';
}

/// Un rayon défini par son [nom].
class Rayon {
  /// Le nom de ce [Rayon].
  String nom;

  /// Crée un nouveau [Rayon] avec son [nom].
  Rayon(this.nom);

  /// Crée un nouveau [Rayon] depuis une [map].
  factory Rayon.fromMap(Map<String, dynamic> map) =>
      Rayon(map['nom'] as String);

  /// Transforme ce [Rayon] en `Map<String, dynamic>`.
  Map<String, dynamic> toMap() => {'nom': nom};

  /// Renvoie une représentation textuelle de ce [Rayon].
  @override
  String toString() => 'Rayon(nom: $nom)';
}

/// Le vue modèle et son contrôleur.
class VueModele extends ChangeNotifier {
  final StorageStrategy _storage;

  late Future<void> _isLoaded;

  final Rayon _divers = Rayon('Divers');

  final List<Rayon> _rayons = [];

  final List<Produit> _produits = [];

  /// Crée le modèle et charge les données suivant la [StorageStrategy] en
  /// paramètre.
  VueModele(this._storage) {
    _isLoaded = loadAll();
    var _storage = this._storage;
    if (_storage is BackendStrategy) _storage.pushEvent = _recoitPublication;
  }

  /// Le [Rayon] 'Divers'.
  Rayon get divers => _divers;

  /// [isConnected] est [true] si le _storage_ est connecté
  bool get isConnected => _storage.isConnected;

  /// [isLoaded] se réalise quand le [loadAll()] initial est terminé.
  Future<void> get isLoaded => _isLoaded;

  /// La liste des produits.
  List<Produit> get produits => _produits;

  /// La liste des rayons.
  List<Rayon> get rayons => _rayons;

  /// La liste des produits avec des quantités > 0.
  List<Produit> get selection =>
      _produits.where((p) => p.quantite > 0).toList();

  /// Déconnexion du storage
  void ctrlDeconnexion() {
    _storage.disconnect();
    notifyListeners();
  }

  /// Met à jour ou ajoute un produit.
  void ctrlMajProduit(Produit? p, Produit maj) {
    Map<String, String>? replace;
    if (p == null) {
      p = _importeProduit(maj);
    } else {
      if (p.nom != maj.nom && !_majNomPossible(maj.nom)) return;
      replace = {'update': p.nom};
      p.nom = maj.nom;
      p.rayon = maj.rayon;
    }
    _trie();
    _changeProduit(p, replace);
    notifyListeners();
  }

  /// Définit la quantite du [Produit] [p] à 0 ou 1.
  void ctrlProduitInverse(Produit p) {
    p.quantite == 0 ? modele.ctrlProduitPlus(p) : modele.ctrlProduitRaz(p);
  }

  /// Décrémente la quantite du [Produit] [p].
  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;
    p.quantite--;
    p.fait = false;
    _changeProduit(p);
  }

  /// Incrémente la quantité du [Produit] [p].
  void ctrlProduitPlus(Produit p) {
    p.quantite++;
    p.fait = false;
    _changeProduit(p);
  }

  /// Marque ou démarque le [Produit] [p].
  void ctrlProduitPrend(Produit p, bool value) {
    p.fait = value;
    _changeProduit(p);
  }

  /// Définit la quantite du [Produit] [p] à 0.
  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    p.fait = false;
    _changeProduit(p);
  }

  /// Valide le charriot et définit les quantités des produits sélectionnés à 0.
  void ctrlValideChariot() {
    _produits.forEach((p) {
      if (p.fait) {
        p.quantite = 0;
        p.fait = false;
        if (isConnected) {
          (_storage as BackendStrategy).advertise('courses/produit', p.toMap());
        }
      }
    });
    notifyListeners();
    saveAll();
  }

  /// Importe une liste de [Produit] et une liste de [Rayon] depuis une [map]
  /// dans ce [VueModele]. Les rayons et produits seront uniques par rapport à
  /// leur nom. Les listes sont triées par ordre alphabétique des noms. La
  /// sélection est mise à jour.
  void importFromMap(Map<String, dynamic> map) {
    _rayons.add(_divers);
    (map['rayons'] as List).forEach((r) => _importeRayon(r['nom'] as String));
    (map['produits'] as List).forEach(
        (p) => _importeProduit(Produit.fromMap(p as Map<String, dynamic>)));
    _trie();
  }

  /// Charge dans le modèle toutes les données du stockage.
  Future<void> loadAll() async {
    try {
      importFromMap(await _storage.read());
    } on Error {
      debugPrint('Erreur de lecture. Fallback sur les données intégrées.');
      importFromMap(await readFromAsset('courses'));
    }
  }

  /// Sauve les données du modèle sur le sockage.
  Future<void> saveAll() async => await _storage.write(toMap());

  /// Transforme ce [VueModele] en `Map<String, dynamic>`
  Map<String, dynamic> toMap() => {
        'rayons': _rayons.map((rayon) => rayon.toMap()).toList(),
        'produits': _produits.map((produit) => produit.toMap()).toList(),
      };

  /// Notifie la vue, sauve en local et publie le produit sur le serveur
  void _changeProduit(Produit p, [Map<String, String>? aux]) {
    p.notifyListeners();
    saveAll();
    _publieProduit(p, aux);
  }

  Produit _importeProduit(Produit produit) {
    var rayon = _importeRayon(produit.rayon.nom);
    produit.rayon = rayon;
    var existant = _produits.singleWhere(
      (p) => p.nom == produit.nom,
      orElse: () => produit,
    );
    if (existant != produit) {
      existant.rayon = produit.rayon;
      existant.quantite = produit.quantite;
      existant.fait = produit.fait;
      return existant;
    } else {
      _produits.add(produit);
      return produit;
    }
  }

  // Callback de push SSE
  Rayon _importeRayon(String nom) {
    Rayon rayon;
    try {
      rayon = _rayons.singleWhere((r) => r.nom == nom);
    } on StateError {
      rayon = Rayon(nom);
      _rayons.add(rayon);
    }
    return rayon;
  }

  bool _majNomPossible(String nom) {
    return _produits.where((p) => p.nom == nom).isEmpty;
  }

  void _publieProduit(Produit p, [Map<String, String>? aux]) async {
    if (isConnected) {
      var map = p.toMap();
      if (aux != null) map.addAll(aux);
      await _storage.advertise('courses/produit', map);
      if (!isConnected) notifyListeners();
    }
  }

  void _recoitPublication(Map<String, dynamic> map) {
    var nouveau = Produit.fromMap(map);
    var ancien_nom = (map['update'] as String?) ?? '';
    _produits.removeWhere((p) => p.nom == ancien_nom || p.nom == nouveau.nom);
    _importeProduit(nouveau);
    _trie();
    notifyListeners();
  }

  void _trie() {
    _rayons.sort((a, b) => a.nom.compareTo(b.nom));
    _produits.sort((a, b) {
      var cmp = a.rayon.nom.compareTo(b.rayon.nom);
      if (cmp == 0) {
        cmp = a.nom.compareTo(b.nom);
      }
      return cmp;
    });
  }
}
