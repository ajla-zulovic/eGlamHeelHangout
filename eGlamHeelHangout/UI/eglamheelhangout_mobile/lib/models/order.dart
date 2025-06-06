import 'package:json_annotation/json_annotation.dart';
import 'orderitem.dart';

part 'order.g.dart';
@JsonSerializable()
class Order {
  final int? orderId;
  final double totalPrice;
  final String orderStatus;
  final String paymentMethod;
  final String? username;
  final DateTime? orderDate;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.totalPrice,
    required this.orderStatus,
    required this.paymentMethod,
    required this.items,
    this.username,
    this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
