/// Cette bibliothèque définit les classes du modèle de données de l'application
/// courses2 : [Rayon], [Produit] et [VueModele].
library modele;

import 'package:courses2/backend.dart';
import 'package:flutter/foundation.dart';
import 'storage.dart';

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

/// Le vue modèle et son contrôleur.
class VueModele extends ChangeNotifier {
  final StorageStrategy _storage;

  late Future<void> _isLoaded;

  /// [isLoaded] se réalise quand le [loadAll()] initial est terminé.
  Future<void> get isLoaded => _isLoaded;

  /// [isConnected] est [true] si le _storage_ est connecté
  bool get isConnected {
    if (_storage is BackendStrategy) {
      return (_storage as BackendStrategy).isConnected;
    } else {
      return false;
    }
  }

  final Rayon _divers = Rayon('Divers');

  /// Le [Rayon] 'Divers'.
  Rayon get divers => _divers;

  final List<Rayon> _rayons = [];

  /// La liste des rayons.
  List<Rayon> get rayons => _rayons;

  final List<Produit> _produits = [];

  /// La liste des produits.
  List<Produit> get produits => _produits;

  final List<Produit> _selection = [];

  /// La liste des produits avec des quantités > 0.
  List<Produit> get selection => _selection;

  /// Crée le modèle et charge les données suivant la [StorageStrategy] en
  /// paramètre.
  VueModele(this._storage) {
    _isLoaded = loadAll();
    if (_storage is BackendStrategy) {
      (_storage as BackendStrategy).pushEvent = _pushProduit;
    }
  }

  /// Incrémente la quantité du [Produit] [p].
  void ctrlProduitPlus(Produit p) {
    if (++p.quantite == 1) {
      _selection.add(p);
      _selection.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    }
    p.fait = false;
    p.notifyListeners();
    saveAll();
    if (isConnected) {
      (_storage as BackendStrategy).push(p.toMap());
    }
  }

  /// Décrémente la quantite du [Produit] [p].
  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;

    if (--p.quantite == 0) {
      _selection.remove(p);
    }
    p.fait = false;
    p.notifyListeners();
    saveAll();
  }

  /// Définit la quantite du [Produit] [p] à 0.
  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    _selection.remove(p);
    p.fait = false;
    p.notifyListeners();
    saveAll();
  }

  /// Définit la quantite du [Produit] [p] à 0 ou 1.
  void ctrlProduitInverse(Produit p) {
    p.quantite == 0 ? modele.ctrlProduitPlus(p) : modele.ctrlProduitRaz(p);
  }

  /// Marque ou démarque le [Produit] [p].
  void ctrlProduitPrend(Produit p, bool value) {
    p.fait = value;
    p.notifyListeners();
    saveAll();
  }

  /// Valide le charriot et définit les quantités des produits sélectionnés à 0.
  void ctrlValideChariot() {
    _selection.removeWhere((p) {
      if (p.fait) {
        p.quantite = 0;
        p.fait = false;
        return true;
      }
      return false;
    });
    notifyListeners();
    saveAll();
  }

  /// Met à jour ou ajoute un produit.
  void ctrlMajProduit(Produit? p, Produit maj) {
    if (p == null) {
      _addSingleProduit(maj);
    } else {
      p.nom = maj.nom;
      p.rayon = maj.rayon;
    }
    _produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    notifyListeners();
    saveAll();
  }

  Rayon _addSingleRayon(String nom) {
    Rayon rayon;
    try {
      rayon = _rayons.singleWhere((r) => r.nom == nom);
    } on StateError {
      rayon = Rayon(nom);
      _rayons.add(rayon);
    }
    return rayon;
  }

  Produit _addSingleProduit(Produit produit) {
    var rayon = _addSingleRayon(produit.rayon.nom);
    produit.rayon = rayon;
    try {
      var existant = _produits.singleWhere((p) => p.nom == produit.nom);
      existant.rayon = produit.rayon;
      existant.quantite = produit.quantite;
      existant.fait = produit.fait;
      return existant;
    } on StateError {
      _produits.add(produit);
      return produit;
    }
  }

  // Callback de push SSE
  void _pushProduit(Map<String, dynamic> map) {
    var p = Produit.fromMap(map);
    var p2 = _addSingleProduit(p);
    // Si le produit existe, on ne notifie que le produit
    if (p != p2) {
      p2.notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// Transforme ce [VueModele] en `Map<String, dynamic>`
  Map<String, dynamic> toMap() => {
        'rayons': _rayons.map((rayon) => rayon.toMap()).toList(),
        'produits': _produits.map((produit) => produit.toMap()).toList(),
      };

  /// Importe une liste de [Produit] et une liste de [Rayon] depuis une [map]
  /// dans ce [VueModele]. Les rayons et produits seront uniques par rapport à
  /// leur nom. Les listes sont triées par ordre alphabétique des noms. La
  /// sélection est mise à jour.
  void importFromMap(Map<String, dynamic> map) {
    _rayons.add(_divers);
    (map['rayons'] as List).forEach((r) => _addSingleRayon(r['nom'] as String));
    (map['produits'] as List).forEach(
        (p) => _addSingleProduit(Produit.fromMap(p as Map<String, dynamic>)));
    _rayons.sort((a, b) => a.nom.compareTo(b.nom));
    _produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    _selection.addAll(_produits.where((e) => e.quantite > 0));
  }

  /// Sauve les données du modèle sur le sockage.
  Future<void> saveAll() async => await _storage.write(toMap());

  /// Charge dans le modèle toutes les données du stockage.
  Future<void> loadAll() async {
    try {
      importFromMap(await _storage.read());
    } on Error {
      debugPrint('Erreur de lecture. Fallback sur les données intégrées.');
      importFromMap(await readFromAsset('courses'));
    }
  }
}

late VueModele modele;
