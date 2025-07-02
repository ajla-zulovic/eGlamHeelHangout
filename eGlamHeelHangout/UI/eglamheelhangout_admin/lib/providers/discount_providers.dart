import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/discount.dart';
import 'base_providers.dart';

class DiscountProvider extends BaseProvider<Discount> {
  DiscountProvider() : super("Discount");
@override
Discount fromJson(Map<String, dynamic> json) {
  return Discount.fromJson(json); 
} 


Future<void> applyDiscount(Discount discount) async {
  var url = "$baseUrl$endpoint";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(discount.toJson()),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final errorMsg = utf8.decode(response.bodyBytes);
    throw Exception("Failed to apply discount: $errorMsg");
  }
}

Future<Discount?> getByProduct(int productId) async {
  var url ="$baseUrl$endpoint/by-product/$productId";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    return Discount.fromJson(jsonDecode(response.body));
  }
  return null;
}

Future<void> remove(int productId) async {
  var url ="$baseUrl$endpoint/$productId";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http.delete(uri, headers: headers);

  if (response.statusCode != 200) throw Exception("Failed to remove discount");
}



}