import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/review.dart';
import 'base_providers.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
Review fromJson(Map<String, dynamic> json) {
  return Review.fromJson(json);
}

Future<double> fetchAverageRating(int productId) async {
  var url = "$baseUrl$endpoint/average/$productId";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    return double.tryParse(response.body) ?? 0;
  } else {
    throw Exception('Failed to load average rating');
  }
}

 
}