import 'package:json_annotation/json_annotation.dart';

part 'giveawaydto.g.dart'; 

@JsonSerializable()
class GiveawayNotification {
  final int? giveawayId;
  final String title;
  final String color;
  final double heelHeight;
  final String description;
  final String? giveawayProductImage;

  GiveawayNotification({
    this.giveawayId,
    required this.title,
    required this.color,
    required this.heelHeight,
    required this.description,
    this.giveawayProductImage,
  });

  factory GiveawayNotification.fromJson(Map<String, dynamic> json) =>
      _$GiveawayNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$GiveawayNotificationToJson(this);
}