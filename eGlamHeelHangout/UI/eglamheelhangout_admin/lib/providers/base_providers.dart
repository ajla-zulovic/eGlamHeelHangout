import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/utils.dart';
import '../models/search_result.dart';
import 'package:eglamheelhangout_admin/models/productsize.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _baseUrl = const String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:7277/",
    );
    _endpoint = endpoint;
  }

  String get baseUrl => _baseUrl ?? "http://localhost:7277/";
  String get endpoint => _endpoint;

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$_endpoint";
    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);
      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        var result = SearchResult<T>();
        result.count = data['count'];
        for (var item in data['result']) {
          result.result.add(fromJson(item));
        }
        return result;
      }
      throw Exception("Invalid response from server");
    } catch (e) {
      print("API Error: ${e.toString()}");
      rethrow;
    }
  }

  T fromJson(Map<String, dynamic> json);

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

    if (username.isEmpty || password.isEmpty) {
      throw Exception("Username and password must be provided");
    }

    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }

  String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) key = '[$key]';
        else if (value is List || value is Map) key = '.$key';
        else key = '.$key';
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value is String ? Uri.encodeComponent(value) : value;
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

Future<T> insert (dynamic request) async
{
    var url = "$baseUrl$_endpoint"; //treba nam putanja do naseg servera i endpoint
    var uri = Uri.parse(url);
    var headers = createHeaders(); //vazno jer ovo mogu samo uraditi korisnci/admini koji su prosli autentifikaciju

    var jsonRequest=jsonEncode(request); //moramo request koji saljemo enkodirati u json
    var response= await http.post(uri,headers:headers,body:jsonRequest);
    print('INSERT status: ${response.statusCode}');
    print('INSERT body: ${response.body}');

  try {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    } else {
      debugPrint("Response is not a JSON object: $decoded");
      return fromJson({});
    }
  } catch (e) {
    debugPrint("EXCEPTION while parsing insert response: $e");
    debugPrint("Raw response: ${response.body}");
    throw Exception("Invalid response format");
  }
}

Future<T> update(int id, [dynamic request]) async {
  var url = "$baseUrl$_endpoint/$id";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var jsonRequest = jsonEncode(request);
  var response = await http.put(uri, headers: headers, body: jsonRequest);

  if (response.statusCode == 204 || response.body.isEmpty || response.body == 'true') {
    return fromJson({});
  }

  if (response.statusCode == 200) {
    try {
  final data = jsonDecode(response.body);
  debugPrint("Decoded update response: $data");
  return fromJson(data);
} catch (e) {
  debugPrint(" Parsing error: $e");
  debugPrint("Raw body: ${response.body}");
  throw Exception("Invalid response format: ${response.body}");
}

  }

  throw Exception("Request failed with status ${response.statusCode}");
}

Future<void> delete(int id) async {
  var url = "$baseUrl$endpoint/$id";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.delete(uri, headers: headers);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Failed to delete: ${response.body}");
  }
}


Future<List<ProductSize>> getProductSizes(int id) async {
  var url = "$baseUrl$endpoint/$id/sizes";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.get(uri, headers: headers);

   if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((item) => ProductSize.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load sizes');
  }
}


Future<T> getById(int id) async {
  var url = "$baseUrl$endpoint/$id";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  final response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    throw Exception("Failed to fetch user by ID");
  }
}


}

//[dynamic request] -> [] zagrade naglasavaju da je ovo opcionalni parametar 
