/// Cette bibliothèque définit les classes du modèle de données de l'application
/// courses2 : [Rayon], [Produit] et [Modele]
library modele;

import 'package:flutter/foundation.dart';
import 'storage.dart';

/// Un rayon défini par son [nom]
class Rayon {
  /// Le nom de ce [Rayon]
  String nom;

  /// Crée un nouveau [Rayon] avec son [nom]
  Rayon(this.nom);

  /// Crée un nouveau [Rayon] depuis une [map]
  factory Rayon.fromMap(Map<String, dynamic> map) =>
      Rayon(map['nom'] as String);

  /// Transforme ce [Rayon] en `Map<String, dynamic>`
  Map<String, dynamic> toMap() => {'nom': nom};

  /// Renvoie une représentation textuelle de ce [Rayon]
  @override
  String toString() => 'Rayon(nom: $nom)';
}

/// Un produit défini par son [nom] et son [rayon]
class Produit extends ChangeNotifier {
  /// Le [nom] de ce [Produit]
  String nom;

  /// Le [rayon] de ce [Produit]
  Rayon rayon;

  /// La [quantite] actuellement sélectionnée
  int quantite;

  /// Indique si ce [Produit] a été placé dans le charriot
  bool fait;

  /// Crée un nouveau Produit avec son [nom] et son [rayon]. Par défaut, la
  /// [quantite] est initialisée à 0 et [fait] à `false`.
  Produit(this.nom, this.rayon, [this.quantite = 0, this.fait = false]);

  /// Crée un nouveau [Produit] depuis une [map]
  factory Produit.fromMap(Map<String, dynamic> map) => Produit(
      map['nom'] as String,
      Rayon.fromMap(map['rayon'] as Map<String, dynamic>),
      map['quantite'] as int,
      map['fait'] as bool);

  /// Transforme ce [Produit] en `Map<String, dynamic>`
  Map<String, dynamic> toMap() =>
      {'nom': nom, 'rayon': rayon.toMap(), 'quantite': quantite, 'fait': fait};

  /// Renvoie une représentation textuelle de ce [Produit]
  @override
  String toString() =>
      'Produit(nom: $nom, rayon: $rayon, quantite: $quantite, fait: $fait)';
}

/// Le modèle et son contrôleur
class Modele extends ChangeNotifier {
  final StorageStrategy _storage;

  /// [isLoaded] se réalise quand le _readAll() initial est terminé.
  Future<void>? isLoaded;

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

  /// Crée le modèle et lit les données suivant la [StorageStrategy] en
  /// paramètre.
  Modele(this._storage) {
    isLoaded = _readAll();
  }

  /// Incrémente la quantité du [Produit] [p].
  void ctrlProduitPlus(Produit p) {
    if (++p.quantite == 1) {
      _selection.add(p);
      _selection.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    }
    p.fait = false;
    p.notifyListeners();
    _writeAll();
  }

  /// Décrémente la quantite du [Produit] [p].
  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;

    if (--p.quantite == 0) {
      _selection.remove(p);
    }
    p.fait = false;
    p.notifyListeners();
    _writeAll();
  }

  /// Définit la quantite du [Produit] [p] à 0.
  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    _selection.remove(p);
    p.fait = false;
    p.notifyListeners();
    _writeAll();
  }

  /// Définit la quantite du [Produit] [p] à 0 ou 1.
  void ctrlProduitInverse(Produit p) {
    p.quantite == 0 ? modele.ctrlProduitPlus(p) : modele.ctrlProduitRaz(p);
  }

  /// Marque ou démarque le [Produit] [p].
  void ctrlProduitPrend(Produit p, bool value) {
    p.fait = value;
    p.notifyListeners();
    _writeAll();
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
    _writeAll();
  }

  /// Met à jour ou ajoute un produit
  void ctrlMajProduit(Produit? p, Produit maj) {
    if (p == null) {
      modele._produits.add(maj);
    } else {
      p.nom = maj.nom;
      p.rayon = maj.rayon;
    }
    _produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    notifyListeners();
    _writeAll();
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

  void _addSingleProduit(Map<String, dynamic> map) {
    var nouveau = Produit.fromMap(map);
    var rayon = _addSingleRayon(nouveau.rayon.nom);
    nouveau.rayon = rayon;
    try {
      var existant = _produits.singleWhere((p) => p.nom == nouveau.nom);
      existant.rayon = nouveau.rayon;
      existant.quantite = nouveau.quantite;
      existant.fait = nouveau.fait;
    } on StateError {
      _produits.add(nouveau);
    }
  }

  /// Transforme ce [Modele] en `Map<String, dynamic>`
  Map<String, dynamic> toMap() => {
        'rayons': _rayons.map((rayon) => rayon.toMap()).toList(),
        'produits': _produits.map((produit) => produit.toMap()).toList(),
      };

  /// Importe une liste de [Produit] et une liste de [Rayon] depuis une [map]
  /// dans ce [Modele]. Les rayons et produits seront uniques par rapport à leur
  /// nom. Les listes sont triées par ordre alphabétique des noms. La sélection
  /// est mise à jour.
  void fromMap(Map<String, dynamic> map) {
    _rayons.add(_divers);
    (map['rayons'] as List).forEach((r) => _addSingleRayon(r['nom'] as String));
    (map['produits'] as List)
        .forEach((p) => _addSingleProduit(p as Map<String, dynamic>));
    _rayons.sort((a, b) => a.nom.compareTo(b.nom));
    _produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    _selection.addAll(_produits.where((e) => e.quantite > 0));
  }

  Future<void> _writeAll() async => await _storage.writeAll(toMap());

  Future<void> _readAll() async => fromMap(await _storage.readAll());
}

late Modele modele;
