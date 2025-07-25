import 'package:flutter/material.dart';
import '../models/category.dart';
import 'base_providers.dart';
import 'package:http/http.dart' as http;

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }

  
  Future<void> activate(int categoryId) async {
    var uri = Uri.parse("$baseUrl$endpoint/$categoryId/active");
    var headers = createHeaders();
    await http.put(uri, headers: headers);
  }

  Future<void> deactivate(int categoryId) async {
    var uri = Uri.parse("$baseUrl$endpoint/$categoryId/deactivate");
    var headers = createHeaders();
    await http.put(uri, headers: headers);
  }
}