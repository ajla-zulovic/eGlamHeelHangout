import 'package:flutter/material.dart';
import 'package:http/http.dart' as http_package;
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

  final response = await http_package.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return fromJson(data);
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

Future<void> promoteToAdmin(int userId) async {
  var url = "$baseUrl$endpoint/$userId/promote";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http_package.post(uri, headers: headers);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception("Failed to promote user: ${response.body}");
  }
}

Future<void> demoteFromAdmin(int userId) async {
  var url = "$baseUrl$endpoint/$userId/demote";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http_package.put(uri, headers: headers);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Failed to demote user: ${response.body}");
  }
}

Future<void> deleteUser(int userId) async {
  var url = "$baseUrl$endpoint/$userId";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http_package.delete(uri, headers: headers);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Failed to delete user: ${response.body}");
  }
}




 
}