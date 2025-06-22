import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
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

  print(">>> [getRecommendedProducts] GET $uri");

  final response = await http!.get(uri, headers: headers);

  print(">>> [getRecommendedProducts] status: ${response.statusCode}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    print(">>> [getRecommendedProducts] parsed ${data.length} items");
    return data.map((e) => Product.fromJson(e)).toList();
  } else {
    print(">>> [getRecommendedProducts] failed: ${response.body}");
    throw Exception('Failed to load recommended products');
  }
}






}