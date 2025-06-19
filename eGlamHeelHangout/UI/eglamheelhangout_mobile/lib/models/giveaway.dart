import 'package:json_annotation/json_annotation.dart';

part 'giveaway.g.dart'; 

@JsonSerializable()
class Giveaway {

final int giveawayId;
  final String title;
  final String color;
  final double heelHeight;
  final String description;
  final DateTime endDate;
  final bool isClosed;
  final String? winnerName;
  final String? giveawayProductImage;

  Giveaway({
    required this.giveawayId,
    required this.title,
    required this.color,
    required this.heelHeight,
    required this.description,
    required this.endDate,
    required this.isClosed,
    this.winnerName,
    this.giveawayProductImage,
  });


    factory Giveaway.fromJson(Map<String, dynamic> json) => _$GiveawayFromJson(json);
    
    Map<String, dynamic> toJson() => _$GiveawayToJson(this);
}