// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modele.dart';

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

ModeleCourses _$ModeleCoursesFromJson(Map<String, dynamic> json) {
  return ModeleCourses(null)
    .._rayons = (json['rayons'] as List)
        ?.map(
            (e) => e == null ? null : Rayon.fromJson(e as Map<String, dynamic>))
        ?.toList()
    .._produits = (json['produits'] as List)
        ?.map((e) =>
            e == null ? null : Produit.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ModeleCoursesToJson(ModeleCourses instance) =>
    <String, dynamic>{
      'rayons': instance._rayons?.map((e) => e?.toJson())?.toList(),
      'produits': instance._produits?.map((e) => e?.toJson())?.toList(),
    };
