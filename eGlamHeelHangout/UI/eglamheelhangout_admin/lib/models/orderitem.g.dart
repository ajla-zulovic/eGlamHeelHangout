// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderitem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  size: (json['size'] as num?)?.toInt(),
  productSizeId: (json['productSizeId'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'quantity': instance.quantity,
  'pricePerUnit': instance.pricePerUnit,
  'size': instance.size,
  'productSizeId': instance.productSizeId,
};
