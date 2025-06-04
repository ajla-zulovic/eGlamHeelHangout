// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paymentcreate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentCreate _$PaymentCreateFromJson(Map<String, dynamic> json) =>
    PaymentCreate(
      orderId: (json['orderId'] as num?)?.toInt(),
      reservationId: (json['reservationId'] as num?)?.toInt(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      paymentMethodId: json['paymentMethodId'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$PaymentCreateToJson(PaymentCreate instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'reservationId': instance.reservationId,
      'totalAmount': instance.totalAmount,
      'paymentMethodId': instance.paymentMethodId,
      'username': instance.username,
    };
