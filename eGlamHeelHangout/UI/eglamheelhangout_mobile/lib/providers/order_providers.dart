import 'package:flutter/material.dart';
import '../models/order.dart';
import '../providers/base_providers.dart';
import 'dart:convert';


class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(Map<String, dynamic> json) {
    return Order.fromJson(json);
  }

  Future<Order?> createOrder(Order order) async {
  final url = "$baseUrl$endpoint/custom-create";
  final uri = Uri.parse(url);
  final headers = createHeaders();
  final jsonBody = jsonEncode(order.toJson());
  final response = await http!.post(uri, headers: headers, body: jsonBody);
  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final parsed = fromJson(data);
      return parsed;
    } catch (e, stacktrace) {
      return null;
    }
  } else if (response.statusCode == 403) {
    throw Exception("You are not authorized to create an order.");
  } else {
    throw Exception("Failed to create order. (${response.statusCode})");
  }
}
Future<List<Order>> getMyOrders() async {
  var url = "$baseUrl$endpoint/my-orders";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http!.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((item) => Order.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load orders: ${response.statusCode}");
  }
}


}
