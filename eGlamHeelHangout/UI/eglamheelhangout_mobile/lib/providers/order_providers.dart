import 'package:flutter/material.dart';
import '../models/order.dart';
import '../providers/base_providers.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(Map<String, dynamic> json) {
    return Order.fromJson(json);
  }

  Future<Order?> createOrder(Order order) async {
    try {
      final response = await insert(order.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
