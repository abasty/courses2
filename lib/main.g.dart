// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rayon _$RayonFromJson(Map<String, dynamic> json) {
  return Rayon(
    json['nom'] as String,
  );
}

Map<String, dynamic> _$RayonToJson(Rayon instance) => <String, dynamic>{
      'nom': instance.nom,
    };

Produit _$ProduitFromJson(Map<String, dynamic> json) {
  return Produit(
    json['nom'] as String,
    json['rayon'] == null
        ? null
        : Rayon.fromJson(json['rayon'] as Map<String, dynamic>),
  )
    ..quantite = json['quantite'] as int
    ..fait = json['fait'] as bool;
}

Map<String, dynamic> _$ProduitToJson(Produit instance) => <String, dynamic>{
      'nom': instance.nom,
      'rayon': instance.rayon?.toJson(),
      'quantite': instance.quantite,
      'fait': instance.fait,
    };

ModeleCoursesSingleton _$DBFromJson(Map<String, dynamic> json) {
  return ModeleCoursesSingleton()
    ..rayons = (json['rayonTable'] as List)
        ?.map(
            (e) => e == null ? null : Rayon.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..produits = (json['produitTable'] as List)
        ?.map((e) =>
            e == null ? null : Produit.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$DBToJson(ModeleCoursesSingleton instance) =>
    <String, dynamic>{
      'rayonTable': instance.rayons?.map((e) => e?.toJson())?.toList(),
      'produitTable': instance.produits?.map((e) => e?.toJson())?.toList(),
    };
