import 'package:flutter/material.dart';
import 'package:http/http.dart' as http_package;
import 'dart:convert';
import '../models/user.dart';
import 'base_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final response = await http!.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final user = fromJson(data);

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("userId", user.userId!);

    return user;
  } else {
    throw Exception("Failed to fetch current user");
  }
}


Future<void> register(Map<String, dynamic> data) async {
  var uri = Uri.parse("$baseUrl$endpoint/register");
  var headers = {
    "Content-Type": "application/json"
  };
  var body = jsonEncode(data);

  final response = await http_package.post(uri, headers: headers, body: body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception("Registration failed: ${response.body}");
  }
}


Future<void> changePassword(Map<String, dynamic> data) async {
  var uri = Uri.parse("$baseUrl$endpoint/change-password");
  var headers = createHeaders();
  var body = jsonEncode(data);

  final response = await http_package.put(uri, headers: headers, body: body);

 if (response.statusCode < 200 || response.statusCode >= 300) {
    throw response;
  }
}


 
}