import 'package:json_annotation/json_annotation.dart';

part 'orderitem.g.dart';

@JsonSerializable()
class OrderItem {
  final int productId;
  final int productSizeId;
  final int quantity;
  final double pricePerUnit;

  OrderItem({
    required this.productId,
    required this.productSizeId,
    required this.quantity,
    required this.pricePerUnit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
