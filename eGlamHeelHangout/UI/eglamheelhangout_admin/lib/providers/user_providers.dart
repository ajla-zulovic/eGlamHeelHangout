import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'base_providers.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
User fromJson(Map<String, dynamic> json) {
  return User.fromJson(json);
}


  Future<User> getCurrentUser() async {
  var url = "$baseUrl$endpoint/current";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    throw Exception("Failed to fetch current user");
  }
}


 
}