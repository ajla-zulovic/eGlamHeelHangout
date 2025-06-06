// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cartitem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  productId: (json['productId'] as num).toInt(),
  sizeId: (json['sizeId'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  image: json['image'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  productSizeId: (json['productSizeId'] as num).toInt(),
  stockQuantity: (json['stockQuantity'] as num).toInt(),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'sizeId': instance.sizeId,
  'size': instance.size,
  'name': instance.name,
  'price': instance.price,
  'image': instance.image,
  'quantity': instance.quantity,
  'stockQuantity': instance.stockQuantity,
  'productSizeId': instance.productSizeId,
};
