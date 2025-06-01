import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import 'base_providers.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(Map<String, dynamic> json) {
    return Product(
    productID: json['productID'],
    name: json['name'],
    price: json['price'],
    description: json['description'],
    color: json['color'],
    material: json['material'],
    heelHeight: json['heelHeight'],
    categoryID: json['categoryID'],
    image: json['image'],
  );
  }

 
}