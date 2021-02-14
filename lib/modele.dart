import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:json_annotation/json_annotation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'modele.g.dart';

@JsonSerializable()
class Rayon {
  String nom;

  Rayon(this.nom);

  factory Rayon.fromJson(Map<String, dynamic> json) => _$RayonFromJson(json);
  Map<String, dynamic> toJson() => _$RayonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Produit {
  String nom;
  Rayon rayon;
  int quantite = 0;
  bool fait = false;

  Produit(this.nom, this.rayon);
  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ModeleStocksSingleton {
  List<Rayon> rayons = [];
  List<Produit> produits = [];

  @JsonKey(ignore: true)
  Rayon rayonDivers;
  @JsonKey(ignore: true)
  List<Produit> listeSelect = [];

  final _storage = LocalStorage('stocks.json');

  ModeleStocksSingleton._privateConstructor();

  static final ModeleStocksSingleton _instance =
      ModeleStocksSingleton._privateConstructor();

  factory ModeleStocksSingleton() {
    return _instance;
  }

  void ctrlProduitPlus(Produit p) {
    if (++p.quantite == 1) {
      listeSelect.add(p);
      listeSelect.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    }
    p.fait = false;
    writeToFile();
  }

  void ctrlProduitMoins(Produit p) {
    if (p.quantite == 0) return;

    if (--p.quantite == 0) {
      listeSelect.remove(p);
    }
    p.fait = false;
    writeToFile();
  }

  void ctrlProduitRaz(Produit p) {
    if (p.quantite == 0) return;
    p.quantite = 0;
    listeSelect.remove(p);
    p.fait = false;
    writeToFile();
  }

  void ctrlProduitInverse(Produit p) {
    p.quantite == 0 ? modele.ctrlProduitPlus(p) : modele.ctrlProduitRaz(p);
  }

  void ctrlProduitPrend(Produit p, value) {
    p.fait = value;
    writeToFile();
  }

  void ctrlValideChariot() {
    listeSelect.removeWhere((p) {
      bool fait = p.fait;
      if (fait) {
        p.quantite = 0;
        p.fait = false;
      }
      return fait;
    });
    writeToFile();
  }

  void ctrlMajProduit(Produit p, Produit maj) {
    if (p == null)
      modele.produits.add(maj);
    else {
      p.nom = maj.nom;
      p.rayon = maj.rayon;
    }
    produits.sort((a, b) => a.rayon.nom.compareTo(b.rayon.nom));
    writeToFile();
  }

  void fromJson(Map<String, dynamic> json) {
    Produit produitFromElement(dynamic e) {
      if (e == null) return null;
      Produit p = Produit.fromJson(e as Map<String, dynamic>);
      Rayon r = rayons?.singleWhere((e) => e.nom == p.rayon.nom);
      p?.rayon = r;
      return p;
    }

    rayons = (json['rayons'] as List)
        ?.map(
            (e) => e == null ? null : Rayon.fromJson(e as Map<String, dynamic>))
        ?.toList();
    produits = (json['produits'] as List)?.map(produitFromElement)?.toList();
    rayonDivers = rayons?.singleWhere((e) => e.nom == "Divers");
    listeSelect.addAll(produits?.where((e) => e.quantite > 0));
  }

  factory ModeleStocksSingleton.fromJson(Map<String, dynamic> json) =>
      _$ModeleStocksSingletonFromJson(json);
  Map<String, dynamic> toJson() => _$ModeleStocksSingletonToJson(this);

  Future<void> readFromFile() async {
    String json;
    await _storage.ready;
    json = await _storage.getItem('modele');
    if (json == null) {
      json = await rootBundle.loadString("assets/stocks.json");
    }
    fromJson(jsonDecode(json));
  }

  Future<void> writeToFile() async {
    await _storage.ready;
    await _storage.setItem("modele", jsonEncode(toJson()));
  }
}

var modele = ModeleStocksSingleton();
