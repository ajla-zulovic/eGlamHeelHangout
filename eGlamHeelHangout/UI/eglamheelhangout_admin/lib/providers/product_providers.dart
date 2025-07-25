import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/discount.dart';
import 'base_providers.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");
@override
Product fromJson(Map<String, dynamic> json) {
  return Product.fromJson(json); 
} 

Future<List<Product>> getDiscountedProducts() async {
 var url ="$baseUrl$endpoint/discounts";
  var uri = Uri.parse(url);
  var headers = createHeaders();
  var response = await http.get(uri, headers: headers);

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

  var response = await http.get(uri, headers: headers);
if (response.statusCode == 200) {
  var data = jsonDecode(response.body);
  return (data as List).map((e) => Product.fromJson(e)).toList();
} else {
  throw Exception("Request failed with status ${response.statusCode}");
}

}


}