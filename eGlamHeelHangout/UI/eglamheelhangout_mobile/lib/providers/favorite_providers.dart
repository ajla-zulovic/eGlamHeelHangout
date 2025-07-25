import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product.dart';
import 'base_providers.dart';

class FavoriteProvider extends BaseProvider<Product> {
  FavoriteProvider() : super("Favorite");

  Future<bool> toggle(int productId) async {
    var url = "$baseUrl$endpoint/toggle";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({"productId": productId});

    final response = await http!.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      await refreshFavorites();
      return decoded["liked"] ?? false;
    } else {
      throw Exception("Failed to toggle favorite");
    }
  }

Set<int> favoriteProductIds = {};

Future<void> refreshFavorites() async {
  final favorites = await getFavorites();
  favoriteProductIds = favorites.map((e) => e.productID!).toSet();
  notifyListeners();
}

bool isFavorite(int productId) => favoriteProductIds.contains(productId);


  Future<List<Product>> getFavorites() async {
    var url = "$baseUrl$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    final response = await http!.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load favorites");
    }
  }

  @override
  Product fromJson(Map<String, dynamic> json) {
    return Product.fromJson(json);
  }
}
