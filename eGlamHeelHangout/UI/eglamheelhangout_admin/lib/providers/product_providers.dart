import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eglamheelhangout_admin/utils/utils.dart';

class ProductProvider with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "Product";

  ProductProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7277/",
    );
  }

  Future<dynamic> get() async {
    var url = "$_baseUrl$_endpoint";
    print("API URL: $url"); // Ispisuje endpoint

    var uri = Uri.parse(url);
    var headers = createHeaders();
    print("Headers: $headers"); // Ispisuje headere

    try {
      print("Sending request to API...");
      var response = await http.get(uri, headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return data;
      }
    } catch (e) {
      print("API Error: ${e.toString()}");
      rethrow;
    }
  }

  //   bool isValidResponse(http.Response response) {
  //     if (response.statusCode < 299) {
  //       return true;
  //     } else if (response.statusCode == 401) {
  //       throw Exception("Unauthorized");
  //     } else {
  //       throw Exception("Something bad happened, please try again!");
  //     }
  //   }
  bool isValidResponse(http.Response response) {
    if (response.statusCode == 200) {
      // Dodajte dodatnu provjeru sadržaja
      try {
        final data = jsonDecode(response.body);
        // Provjerite da li odgovor sadrži očekivane podatke
        if (data['result'] == null) {
          throw Exception("Invalid credentials - no data returned");
        }
        return true;
      } catch (e) {
        throw Exception("Invalid response format");
      }
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized - Invalid username or password");
    } else {
      throw Exception("Request failed with status ${response.statusCode}");
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";

    // Dodajte provjeru za prazne vjerodajnice
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Username and password must be provided");
    }

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }
}
