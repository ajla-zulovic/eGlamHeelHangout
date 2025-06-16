// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'giveaway.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Giveaway _$GiveawayFromJson(Map<String, dynamic> json) => Giveaway(
  giveawayId: (json['giveawayId'] as num).toInt(),
  title: json['title'] as String,
  color: json['color'] as String,
  heelHeight: json['heelHeight'] as String,
  description: json['description'] as String,
  endDate: DateTime.parse(json['endDate'] as String),
  isClosed: json['isClosed'] as bool,
  winnerName: json['winnerName'] as String?,
  giveawayProductImage: json['giveawayProductImage'] as String?,
);

Map<String, dynamic> _$GiveawayToJson(Giveaway instance) => <String, dynamic>{
  'giveawayId': instance.giveawayId,
  'title': instance.title,
  'color': instance.color,
  'heelHeight': instance.heelHeight,
  'description': instance.description,
  'endDate': instance.endDate.toIso8601String(),
  'isClosed': instance.isClosed,
  'winnerName': instance.winnerName,
  'giveawayProductImage': instance.giveawayProductImage,
};
