// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: (json['orderId'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  orderStatus: json['orderStatus'] as String,
  paymentMethod: json['paymentMethod'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  username: json['username'] as String?,
  orderDate:
      json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'orderId': instance.orderId,
  'totalPrice': instance.totalPrice,
  'orderStatus': instance.orderStatus,
  'paymentMethod': instance.paymentMethod,
  'username': instance.username,
  'orderDate': instance.orderDate?.toIso8601String(),
  'items': instance.items,
};
