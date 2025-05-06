// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  (json['productID'] as num?)?.toInt(),
  json['name'] as String?,
  json['description'] as String?,
  (json['price'] as num?)?.toDouble(),
  json['imageUrl'] as String?,
  (json['categoryID'] as num?)?.toInt(),
  json['material'] as String?,
  json['color'] as String?,
  (json['heelHeight'] as num?)?.toDouble(),
  json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  json['isActive'] as bool?,
  json['stateMachine'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'productID': instance.productID,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'categoryID': instance.categoryID,
  'material': instance.material,
  'color': instance.color,
  'heelHeight': instance.heelHeight,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isActive': instance.isActive,
  'stateMachine': instance.stateMachine,
};
