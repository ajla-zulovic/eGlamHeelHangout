import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import 'base_providers.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");
@override
Product fromJson(Map<String, dynamic> json) {
  return Product.fromJson(json); 
} 
}