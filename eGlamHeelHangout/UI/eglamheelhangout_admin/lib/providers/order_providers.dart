import 'package:flutter/material.dart';
import '../models/order.dart';
import 'base_providers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(Map<String, dynamic> json) {
    return Order.fromJson(json);
  }

Future<List<Order>> getAllOrders() async {

  var url = "$baseUrl$endpoint";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.get(uri, headers: headers);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    var data = jsonDecode(response.body);
    List<Order> result = (data['result'] as List).map((x) => Order.fromJson(x)).toList();
    return result;
  } else {
    throw Exception("Failed to load orders");
  }
}

Future<void> updateOrderStatus(int orderId, String newStatus) async {
  var url = "$baseUrl$endpoint/update-status";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var jsonRequest = jsonEncode({
    "orderId": orderId,
    "orderStatus": newStatus,
  });

  var response = await http.put(uri, headers: headers, body: jsonRequest);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    print("Order status updated successfully");
  } else {
    throw Exception("Failed to update order status");
  }
}


}