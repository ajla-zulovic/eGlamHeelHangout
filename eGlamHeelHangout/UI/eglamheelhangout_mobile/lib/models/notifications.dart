import 'package:json_annotation/json_annotation.dart';

part 'notifications.g.dart';
@JsonSerializable()
class Notifications {
 
  final int? notificationId;
  final int? userId; 
  final String? message;
  final String? notificationType;
  final DateTime? dateSent;
  bool? isRead;
  final int? productId;
  final int? giveawayId;
  final String? productName;
  final String? giveawayTitle;

  Notifications({
    this.notificationId,
    this.userId,
    this.message,
    this.notificationType,
    this.dateSent,
    this.isRead,
    this.productId,
    this.giveawayId,
    this.productName,
    this.giveawayTitle,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => _$NotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}
