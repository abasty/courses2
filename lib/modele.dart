import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage.dart';

class Rayon {
  String nom;

  Rayon(this.nom);

  Map<String, dynamic> toMap() => {'nom': nom};

  factory Rayon.fromMap(Map<String, dynamic> map) {
    return Rayon(map['nom'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Rayon.fromJson(String source) =>
      Rayon.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Rayon(nom: $nom)';
}

class Produit extends ChangeNotifier {
  String nom;
  Rayon rayon;
  int quantite = 0;
  bool fait = false;

  Produit(this.nom, this.rayon);

  Map<String, dynamic> toMap() =>
      {'nom': nom, 'rayon': rayon.toMap(), 'quantite': quantite, 'fait': fait};

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(map['nom'] as String,
        Rayon.fromMap(map['rayon'] as Map<String, dynamic>))
      ..quantite = map['quantite'] as int
      ..fait = map['fait'] as bool;
  }

  String toJson() => json.encode(toMap());

  factory Produit.fromJson(String source) =>
      Produit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Produit(nom: $nom, rayon: $rayon, quantite: $quantite, fait: $fait)';
  }
}

class ModeleCourses extends ChangeNotifier {
  final StorageCourses _storage;
  Future<void>? isLoaded;

  final Rayon _divers = Rayon('Divers');
  Rayon get divers => _divers;

  final List<Rayon> _rayons = [];
  List<Rayon> get rayons => _rayons;

  final List<Produit> _produits = [];
  List<Produit> get produits => _produits;

  final List<Produit> _selection = [];
  List<Produit> get selection => _selection;

  ModeleCourses(this._storage);

  void ctrlProduitPlus(Produit p) {
    if (++p.quantite == 1) {
      _selection.add(p);
      _selection.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    }
    p.fait = false;
    p.notifyListeners();
    writeAll();
  }

  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;

    if (--p.quantite == 0) {
      _selection.remove(p);
    }
    p.fait = false;
    p.notifyListeners();
    writeAll();
  }

  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    _selection.remove(p);
    p.fait = false;
    p.notifyListeners();
    writeAll();
  }

  void ctrlProduitInverse(Produit p) {
    p.quantite == 0 ? modele.ctrlProduitPlus(p) : modele.ctrlProduitRaz(p);
  }

  void ctrlProduitPrend(Produit p, bool value) {
    p.fait = value;
    p.notifyListeners();
    writeAll();
  }

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
    writeAll();
  }

  void ctrlMajProduit(Produit? p, Produit maj) {
    if (p == null) {
      modele._produits.add(maj);
    } else {
      p.nom = maj.nom;
      p.rayon = maj.rayon;
    }
    _produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    notifyListeners();
    writeAll();
  }

  void readAll() => isLoaded = _readAll();

  Future<void> writeAll() async => await _storage.writeAll(_toMap());

  Future<void> _readAll() async => _fromMap(await _storage.readAll());

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

  void _addProduitMap(Map<String, dynamic> map) {
    var produit = Produit.fromMap(map);
    var rayon = _addSingleRayon(produit.rayon.nom);
    produit.rayon = rayon;
    try {
      _produits.singleWhere((p) => p.nom == produit.nom);
    } on StateError {
      _produits.add(produit);
    }
  }

  Map<String, dynamic> _toMap() => {
        'rayons': _rayons.map((x) => x.toMap()).toList(),
        'produits': _produits.map((x) => x.toMap()).toList(),
      };

  void _fromMap(Map<String, dynamic> map) {
    _rayons.add(_divers);
    (map['rayons'] as List).forEach((r) => _addSingleRayon(r['nom'] as String));
    (map['produits'] as List)
        .forEach((p) => _addProduitMap(p as Map<String, dynamic>));
    _rayons.sort((a, b) => a.nom.compareTo(b.nom));
    _selection.addAll(_produits.where((e) => e.quantite > 0));
  }
}

late ModeleCourses modele;
