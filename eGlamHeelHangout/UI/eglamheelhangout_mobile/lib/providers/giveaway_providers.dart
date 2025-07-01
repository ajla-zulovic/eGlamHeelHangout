import 'package:eglamheelhangout_mobile/models/giveaway.dart';
import 'package:eglamheelhangout_mobile/providers/base_providers.dart';
import 'dart:convert';
import 'package:eglamheelhangout_mobile/models/winner_notification_entity.dart';

class GiveawayProvider extends BaseProvider<Giveaway> {
  GiveawayProvider() : super("Giveaway");

  @override
  Giveaway fromJson(Map<String, dynamic> json) {
    return Giveaway.fromJson(json);
  }

  Future<List<Giveaway>> getActive() async {
    var uri = Uri.parse("${baseUrl}${endpoint}/active");
    var response = await http!.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Giveaway.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load active giveaways");
    }
  }

  Future<dynamic> getUserNotifications() async {
    var uri = Uri.parse("${baseUrl}${endpoint}/user/notifications");
    var response = await http!.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load notifications");
    }
  }
Future<void> participate(Map<String, dynamic> data) async {
  final uri = Uri.parse("${baseUrl}${endpoint}/participate");

  final response = await http!.post(
    uri,
    headers: createHeaders(),
    body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
    try {
      final error = jsonDecode(response.body);

      if (error is Map && error.containsKey("errors")) {
        final errors = error["errors"];
        if (errors is Map && errors.containsKey("ERROR")) {
          final msg = errors["ERROR"];
          if (msg is List && msg.isNotEmpty) {
            throw Exception(msg.first);
          }
        }
      }

      throw Exception("Failed to participate");
    } catch (e) {
      throw Exception(" ${e.toString()}");
    }
  }
}
Future<List<Giveaway>> getFinishedWithWinner() async {
  final uri = Uri.parse("${baseUrl}${endpoint}/user/finished-with-winner");

  final response = await http!.get(uri, headers: createHeaders());

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Giveaway.fromJson(json)).toList();
  } else if (response.statusCode == 404) {
    
    return [];
  } else {
    throw Exception("Failed to load finished giveaways with winners");
  }
}


}
