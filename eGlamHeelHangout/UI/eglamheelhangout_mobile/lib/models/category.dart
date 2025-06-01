import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart'; 

@JsonSerializable()
class Category {
   @JsonKey(name: 'categoryId') // <--- koristi se 'categoryId' iz JSON-a
    int? categoryID;
    String? categoryName;

    Category(
      this.categoryID,
      this.categoryName,
     
    );

    factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
    
    Map<String, dynamic> toJson() => _$CategoryToJson(this);
}