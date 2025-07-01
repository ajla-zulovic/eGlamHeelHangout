// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    Notifications(
      notificationId: (json['notificationId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      message: json['message'] as String?,
      notificationType: json['notificationType'] as String?,
      dateSent:
          json['dateSent'] == null
              ? null
              : DateTime.parse(json['dateSent'] as String),
      isRead: json['isRead'] as bool?,
      productId: (json['productId'] as num?)?.toInt(),
      giveawayId: (json['giveawayId'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      giveawayTitle: json['giveawayTitle'] as String?,
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'message': instance.message,
      'notificationType': instance.notificationType,
      'dateSent': instance.dateSent?.toIso8601String(),
      'isRead': instance.isRead,
      'productId': instance.productId,
      'giveawayId': instance.giveawayId,
      'productName': instance.productName,
      'giveawayTitle': instance.giveawayTitle,
    };
