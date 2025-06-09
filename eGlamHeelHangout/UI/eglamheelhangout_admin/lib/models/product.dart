import 'package:json_annotation/json_annotation.dart';
import 'productsize.dart';
part 'product.g.dart'; 

@JsonSerializable()
class Product {
 @JsonKey(name: 'productID')
  int? productID;
  String? name;
  String? description;
  double? price;
  String? image;
  int? categoryID;
  String? material;
  String? color;
  double? heelHeight;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isActive;
  String? stateMachine;
  bool? isFavorite;
  List<ProductSize>? sizes;

  Product({
    this.productID,
    this.name,
    this.description,
    this.price,
    this.image,
    this.categoryID,
    this.material,
    this.color,
    this.heelHeight,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.stateMachine,
    this.isFavorite,
    this.sizes
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
