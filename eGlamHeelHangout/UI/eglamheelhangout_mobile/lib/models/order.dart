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
  final String? fullName;
  final String? email;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? phoneNumber;

  Order({
    required this.orderId,
    required this.totalPrice,
    required this.orderStatus,
    required this.paymentMethod,
    required this.items,
    this.fullName,
    this.email,
    this.address,
    this.city,
    this.postalCode,
    this.username,
    this.orderDate,
    this.phoneNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
