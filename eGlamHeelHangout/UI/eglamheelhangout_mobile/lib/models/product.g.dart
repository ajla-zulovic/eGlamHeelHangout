// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  productID: (json['productID'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  image: json['image'] as String?,
  categoryID: (json['categoryID'] as num?)?.toInt(),
  material: json['material'] as String?,
  color: json['color'] as String?,
  heelHeight: (json['heelHeight'] as num?)?.toDouble(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool?,
  stateMachine: json['stateMachine'] as String?,
)..isFavorite = json['isFavorite'] as bool?;

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'productID': instance.productID,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'image': instance.image,
  'categoryID': instance.categoryID,
  'material': instance.material,
  'color': instance.color,
  'heelHeight': instance.heelHeight,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isActive': instance.isActive,
  'stateMachine': instance.stateMachine,
  'isFavorite': instance.isFavorite,
};
