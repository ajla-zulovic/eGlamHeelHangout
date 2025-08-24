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


Future<String> updateOrderStatus(int orderId, String newStatus) async {
  final uri = Uri.parse('$baseUrl$endpoint/$orderId/status'); 
  final resp = await http.put(
    uri,
    headers: {
      ...createHeaders(),
      'Content-Type': 'application/json',
    },
    body: jsonEncode(newStatus), 
  );

  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    var msg = resp.body;                
    if (msg.startsWith('"') && msg.endsWith('"')) {
      msg = msg.substring(1, msg.length - 1); 
    }
    return msg;
  } else {
    throw Exception('Failed (${resp.statusCode}) ${resp.body}');
  }
}


}