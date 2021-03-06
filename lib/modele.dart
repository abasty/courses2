import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage.dart';

class Rayon {
  String nom;

  Rayon(this.nom);

  Rayon copyWith({
    String nom,
  }) {
    return Rayon(
      nom ?? this.nom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
    };
  }

  factory Rayon.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Rayon(
      map['nom'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rayon.fromJson(String source) =>
      Rayon.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Rayon(nom: $nom)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Rayon && o.nom == nom;
  }

  @override
  int get hashCode => nom.hashCode;
}

class Produit extends ChangeNotifier {
  String nom;
  Rayon rayon;
  int quantite = 0;
  bool fait = false;

  Produit(this.nom, this.rayon);

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'rayon': rayon?.toMap(),
      'quantite': quantite,
      'fait': fait,
    };
  }

  factory Produit.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

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

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Produit &&
        o.nom == nom &&
        o.rayon == rayon &&
        o.quantite == quantite &&
        o.fait == fait;
  }

  @override
  int get hashCode {
    return nom.hashCode ^ rayon.hashCode ^ quantite.hashCode ^ fait.hashCode;
  }
}

class ModeleCourses extends ChangeNotifier {
  final StorageCourses _storage;
  Future<void> isLoaded;

  List<Rayon> _rayons = [];
  List<Rayon> get rayons => _rayons;

  List<Produit> _produits = [];
  List<Produit> get produits => _produits;

  Rayon _rayonDivers;
  Rayon get rayonDivers => _rayonDivers;

  final List<Produit> _produitsCheck = [];
  List<Produit> get produitsCheck => _produitsCheck;

  ModeleCourses(this._storage);

  void ctrlProduitPlus(Produit p) {
    if (++p.quantite == 1) {
      _produitsCheck.add(p);
      _produitsCheck.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    }
    p.fait = false;
    p.notifyListeners();
    writeAll();
  }

  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;

    if (--p.quantite == 0) {
      _produitsCheck.remove(p);
    }
    p.fait = false;
    //p.notifyListeners();
    notifyListeners();
    writeAll();
  }

  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    _produitsCheck.remove(p);
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
    _produitsCheck.removeWhere((p) {
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

  void ctrlMajProduit(Produit p, Produit maj) {
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

  void fromMap(Map<String, dynamic> json) {
    Produit produitFromElement(dynamic e) {
      if (e == null) return null;
      var p = Produit.fromMap(e as Map<String, dynamic>);
      var r = _rayons?.singleWhere(
        (e) => e.nom == p.rayon.nom,
        orElse: () {
          var r = Rayon(p.rayon.nom);
          _rayons.add(r);
          return r;
        },
      );

      p?.rayon = r;
      return p;
    }

    _rayons = (json['rayons'] as List)
        ?.map(
            (e) => e == null ? null : Rayon.fromMap(e as Map<String, dynamic>))
        ?.toList();
    _produits = (json['produits'] as List)?.map(produitFromElement)?.toList();
    _rayonDivers = _rayons?.singleWhere((e) => e.nom == 'Divers', orElse: () {
      var r = Rayon('Divers');
      _rayons.add(r);
      return r;
    });
    _rayons.sort((a, b) => a.nom.compareTo(b.nom));
    _produitsCheck?.addAll(_produits?.where((e) => e.quantite > 0));
  }

  String toJson() => json.encode(toMap());

  void fromJson(String source) =>
      fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> _readAll() async {
    fromMap(await _storage.readAll());
  }

  void readAll() {
    isLoaded = _readAll();
  }

  Future<void> writeAll() async {
    return await _storage.writeAll(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      '_rayons': _rayons?.map((x) => x?.toMap())?.toList(),
      '_produits': _produits?.map((x) => x?.toMap())?.toList(),
    };
  }

  // factory ModeleCourses.fromMap(Map<String, dynamic> map) {
  //   if (map == null) return null;

  //   return ModeleCourses(
  //     StorageCourses.fromMap(map['_storage']),
  //     Future<void>.fromMap(map['isLoaded']),
  //     List<Rayon>.from(map['_rayons']?.map((x) => Rayon.fromMap(x))),
  //     List<Produit>.from(map['_produits']?.map((x) => Produit.fromMap(x))),
  //     Rayon.fromMap(map['_rayonDivers']),
  //   );
  // }

}

ModeleCourses modele;
