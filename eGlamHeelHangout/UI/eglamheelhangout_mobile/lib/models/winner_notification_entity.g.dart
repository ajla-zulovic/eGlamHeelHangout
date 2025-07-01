// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'winner_notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WinnerNotificationEntity _$WinnerNotificationEntityFromJson(
  Map<String, dynamic> json,
) => WinnerNotificationEntity(
  id: (json['id'] as num).toInt(),
  giveawayId: (json['giveawayId'] as num).toInt(),
  giveawayTitle: json['giveawayTitle'] as String,
  winnerUserId: (json['winnerUserId'] as num).toInt(),
  winnerUsername: json['winnerUsername'] as String,
  notificationDate: DateTime.parse(json['notificationDate'] as String),
);

Map<String, dynamic> _$WinnerNotificationEntityToJson(
  WinnerNotificationEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'giveawayId': instance.giveawayId,
  'giveawayTitle': instance.giveawayTitle,
  'winnerUserId': instance.winnerUserId,
  'winnerUsername': instance.winnerUsername,
  'notificationDate': instance.notificationDate.toIso8601String(),
};
