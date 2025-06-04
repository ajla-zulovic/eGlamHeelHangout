import 'package:json_annotation/json_annotation.dart';

part 'cartitem.g.dart'; 

@JsonSerializable()
class CartItem {
  final int productId;
  final int sizeId;
  final int size;
  final String name;
  final double price;
  final String? image;
  int quantity;
  final int stockQuantity;


  CartItem({
    required this.productId,
    required this.sizeId,
    required this.size,
    required this.name,
    required this.price,
    this.image,
    this.quantity = 1,
    required this.stockQuantity,
  });

  
    factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
    
    Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
