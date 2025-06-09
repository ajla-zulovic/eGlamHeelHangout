import 'package:json_annotation/json_annotation.dart';

part 'productsize.g.dart'; 

@JsonSerializable()
class ProductSize {
  final int? productSizeId;
  final int size;
  final int stockQuantity;

  ProductSize({
   this.productSizeId,
   required  this.size,
   required  this.stockQuantity,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) => _$ProductSizeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductSizeToJson(this);
}
