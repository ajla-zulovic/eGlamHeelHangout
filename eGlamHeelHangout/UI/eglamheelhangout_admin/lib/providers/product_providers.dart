import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eglamheelhangout_admin/utils/utils.dart';
import 'package:eglamheelhangout_admin/models/product.dart'; 
import 'package:eglamheelhangout_admin/models/search_result.dart'; 
import 'package:eglamheelhangout_admin/models/product.dart';
class ProductProvider with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "Product";
 String get baseUrl => _baseUrl ?? "http://localhost:7277/";
  ProductProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7277/",
    );
  }

Future<SearchResult<Product>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";
    print("API URL: $url");
      if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();
    print("Headers: $headers");

    try {
      print("Sending request to API...");
      var response = await http.get(uri, headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        var result = SearchResult<Product>();
        result.count = data['count'];
        for (var item in data['result']) {
          result.result.add(Product.fromJson(item));
        }
        return result;
      }
      throw Exception("Invalid response from server");
    } catch (e) {
      print("API Error: ${e.toString()}");
      rethrow;
    }
  }


  bool isValidResponse(http.Response response) {
    if (response.statusCode == 200) {
    
      try {
        final data = jsonDecode(response.body);
      
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

  String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }
}
