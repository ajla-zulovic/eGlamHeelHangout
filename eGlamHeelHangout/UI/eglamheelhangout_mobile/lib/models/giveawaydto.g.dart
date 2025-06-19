// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'giveawaydto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GiveawayNotification _$GiveawayNotificationFromJson(
  Map<String, dynamic> json,
) => GiveawayNotification(
  giveawayId: (json['giveawayId'] as num?)?.toInt(),
  title: json['title'] as String,
  color: json['color'] as String,
  heelHeight: (json['heelHeight'] as num).toDouble(),
  description: json['description'] as String,
  giveawayProductImage: json['giveawayProductImage'] as String?,
);

Map<String, dynamic> _$GiveawayNotificationToJson(
  GiveawayNotification instance,
) => <String, dynamic>{
  'giveawayId': instance.giveawayId,
  'title': instance.title,
  'color': instance.color,
  'heelHeight': instance.heelHeight,
  'description': instance.description,
  'giveawayProductImage': instance.giveawayProductImage,
};
