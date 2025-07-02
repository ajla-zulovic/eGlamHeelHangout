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
Future<Discount?> getByProduct(int productId) async {
  var url = "$baseUrl$endpoint/by-product/$productId";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    return Discount.fromJson(jsonDecode(response.body));
  }
  return null;
}




}