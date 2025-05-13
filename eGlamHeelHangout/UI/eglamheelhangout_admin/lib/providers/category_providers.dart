import 'package:flutter/material.dart';
import '../models/category.dart';
import 'base_providers.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }
}