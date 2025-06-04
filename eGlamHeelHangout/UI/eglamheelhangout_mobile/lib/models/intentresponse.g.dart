// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intentresponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntentResponse _$IntentResponseFromJson(Map<String, dynamic> json) =>
    IntentResponse(
      paymentIntentId: json['paymentIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
    );

Map<String, dynamic> _$IntentResponseToJson(IntentResponse instance) =>
    <String, dynamic>{
      'paymentIntentId': instance.paymentIntentId,
      'clientSecret': instance.clientSecret,
    };
