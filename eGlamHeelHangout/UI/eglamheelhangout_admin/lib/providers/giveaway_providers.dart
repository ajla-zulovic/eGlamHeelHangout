import 'package:flutter/material.dart';
import '../models/giveaway.dart';
import 'base_providers.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart'; 
import 'dart:convert';

class GiveawayProvider extends BaseProvider<Giveaway> {
  GiveawayProvider() : super("Giveaway");

  @override
  Giveaway fromJson(Map<String, dynamic> json) {
    return Giveaway.fromJson(json);
  }

Future<SearchResult<Giveaway>> getFiltered({bool? isActive}) async {
  var url = "$baseUrl${endpoint}/admin/filter";

  if (isActive != null) {
    url += "?isActive=$isActive";
  }

  var uri = Uri.parse(url);
  var headers = createHeaders();

  var response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    var result = SearchResult<Giveaway>();
    result.count = data['count'];

    for (var item in data['result']) {
      result.result.add(fromJson(item)); 
    }

    return result;
  } else {
    throw Exception("Failed to fetch filtered giveaways");
  }
}


  Future<void> pickWinner(int giveawayId) async {
    var url = "$baseUrl$endpoint/$giveawayId/pick-winner";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers, body: jsonEncode({}));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to pick winner: ${response.body}");
    }
  }
}
