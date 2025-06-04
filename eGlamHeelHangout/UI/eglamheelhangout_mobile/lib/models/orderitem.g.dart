// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderitem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: (json['productId'] as num).toInt(),
  productSizeId: (json['productSizeId'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'productId': instance.productId,
  'productSizeId': instance.productSizeId,
  'quantity': instance.quantity,
  'pricePerUnit': instance.pricePerUnit,
};
