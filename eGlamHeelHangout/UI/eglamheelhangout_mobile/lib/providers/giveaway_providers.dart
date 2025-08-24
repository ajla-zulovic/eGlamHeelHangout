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
  final uri = Uri.parse('$baseUrl$endpoint/participate');

  final response = await http!.post(
    uri,
    headers: {...createHeaders(), 'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) return;

  String msg = 'Failed to participate';
  try {
    final body = jsonDecode(response.body);

    if (body is Map && body['errors'] is Map) {
      final errs = body['errors'] as Map;
      if (errs['ERROR'] is List && (errs['ERROR'] as List).isNotEmpty) {
        msg = (errs['ERROR'] as List).first.toString();
      } else {
        for (final v in errs.values) {
          if (v is List && v.isNotEmpty) { msg = v.first.toString(); break; }
          if (v is String && v.isNotEmpty) { msg = v; break; }
        }
      }
    } else if (body is Map && body['message'] is String) {
      msg = body['message'];
    } else if (body is Map && body['title'] is String) {
      msg = body['title'];
    }
  } catch (_) {}

  throw Exception(msg); 
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
