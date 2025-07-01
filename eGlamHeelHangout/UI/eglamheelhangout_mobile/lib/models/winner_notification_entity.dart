import 'package:json_annotation/json_annotation.dart';

part 'winner_notification_entity.g.dart'; 

@JsonSerializable()
class WinnerNotificationEntity {
  final int id; 
  final int giveawayId;
  final String giveawayTitle;
  final int winnerUserId;
  final String winnerUsername;
  final DateTime notificationDate;

  WinnerNotificationEntity({
    required this.id,
    required this.giveawayId,
    required this.giveawayTitle,
    required this.winnerUserId,
    required this.winnerUsername,
    required this.notificationDate,
  });

  
  factory WinnerNotificationEntity.fromJson(Map<String, dynamic> json) => _$WinnerNotificationEntityFromJson(json);
  Map<String, dynamic> toJson() => _$WinnerNotificationEntityToJson(this);
}