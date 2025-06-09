import 'package:json_annotation/json_annotation.dart';

part 'orderitem.g.dart';

@JsonSerializable()
class OrderItem {
  final int productId;
  final String? productName;
  final int quantity;
  final double pricePerUnit;
  final int? size;
  final int productSizeId;

  OrderItem({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.pricePerUnit,
    this.size,
    required this.productSizeId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
