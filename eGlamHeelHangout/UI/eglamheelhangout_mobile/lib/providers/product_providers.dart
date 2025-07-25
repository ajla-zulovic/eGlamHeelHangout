import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product.dart';
import '../providers/base_providers.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(Map<String, dynamic> json) => Product.fromJson(json);
Future<List<Product>> getRecommendedProducts(int userId) async {
  final url = "$baseUrl$endpoint/$userId/recommend";
  final uri = Uri.parse(url);
  final headers = createHeaders();
  final response = await http!.get(uri, headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load recommended products');
  }
}
Future<List<Product>> getDiscountedProducts() async {
 var url ="$baseUrl$endpoint/discounts";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http!.get(uri, headers: headers);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    if (data['result'] != null) {
      List list = data['result'];
      return list.map((item) => Product.fromJson(item)).toList();
    }
  }

  throw Exception("Failed to load discounted products");
}
Future<List<Product>> getActiveDiscountedProducts() async {
  var url = "${baseUrl}Discount/active";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http!.get(uri, headers: headers);
if (response.statusCode == 200) {
  var data = jsonDecode(response.body);
  return (data as List).map((e) => Product.fromJson(e)).toList();
} else {
  throw Exception("Request failed with status ${response.statusCode}");
}
}
}