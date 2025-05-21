import 'package:json_annotation/json_annotation.dart';

part 'giveaway.g.dart'; 

@JsonSerializable()
class Giveaway {

    int? giveawayId;
    String title;
    String color;
    String heelHeight;
    String description;
    DateTime endDate;
    String giveawayProductImage;


    Giveaway({
    this.giveawayId,
    required this.title,
    required this.color,
    required this.heelHeight,
    required this.description,
    required this.endDate,
    required this.giveawayProductImage,
     
});

    factory Giveaway.fromJson(Map<String, dynamic> json) => _$GiveawayFromJson(json);
    
    Map<String, dynamic> toJson() => _$GiveawayToJson(this);
}