import 'package:json_annotation/json_annotation.dart';

part 'giveaway.g.dart'; 

@JsonSerializable()
class Giveaway {

    int? giveawayId;
    String title;
    String color;
    double heelHeight;
    String description;
    DateTime endDate;
    String giveawayProductImage;
    String? winnerName; 
    bool isClosed;



    Giveaway({
    this.giveawayId,
    required this.title,
    required this.color,
    required this.heelHeight,
    required this.description,
    required this.endDate,
    required this.giveawayProductImage,
    this.winnerName,
    required this.isClosed,
     
});

    factory Giveaway.fromJson(Map<String, dynamic> json) => _$GiveawayFromJson(json);
    
    Map<String, dynamic> toJson() => _$GiveawayToJson(this);
}