import 'dart:convert' show jsonEncode;
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:courses2/storage.dart';

part 'modele.g.dart';

@JsonSerializable()
class Rayon {
  String nom;

  Rayon(this.nom);

  factory Rayon.fromJson(Map<String, dynamic> json) => _$RayonFromJson(json);
  Map<String, dynamic> toJson() => _$RayonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Produit extends ChangeNotifier {
  String nom;
  Rayon rayon;
  int quantite = 0;
  bool fait = false;

  Produit(this.nom, this.rayon);
  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable(explicitToJson: true) // create_factory: false
class ModeleCourses extends ChangeNotifier {
  final StorageCourses _storage;
  Future<void> isLoaded;

  List<Rayon> _rayons = [];
  List<Rayon> get rayons => _rayons;

  List<Produit> _produits = [];
  List<Produit> get produits => _produits;

  @JsonKey(ignore: true)
  Rayon _rayonDivers;
  Rayon get rayonDivers => _rayonDivers;

  @JsonKey(ignore: true)
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

  void fromJson(Map<String, dynamic> json) {
    Produit produitFromElement(dynamic e) {
      if (e == null) return null;
      var p = Produit.fromJson(e as Map<String, dynamic>);
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
            (e) => e == null ? null : Rayon.fromJson(e as Map<String, dynamic>))
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

  // ignore: unused_element
  factory ModeleCourses._fromJson(Map<String, dynamic> json) =>
      _$ModeleCoursesFromJson(json);

  Map<String, dynamic> toJson() => _$ModeleCoursesToJson(this);

  Future<void> _readAll() async {
    fromJson(await _storage.readAll());
  }

  void readAll() {
    isLoaded = _readAll();
  }

  Future<void> writeAll() async {
    return await _storage.writeAll(toJson());
  }
}

ModeleCourses modele;
