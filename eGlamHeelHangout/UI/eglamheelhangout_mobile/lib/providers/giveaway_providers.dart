import 'package:eglamheelhangout_mobile/models/giveaway.dart';
import 'package:eglamheelhangout_mobile/providers/base_providers.dart';
import 'dart:convert';

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

  Future<void> participate({
    required int giveawayId,
    required int size,
    required String address,
    required String postalCode,
    required String city,
  }) async {
    var uri = Uri.parse("${baseUrl}${endpoint}/participate");

    var body = jsonEncode({
      "giveawayId": giveawayId,
      "size": size,
      "address": address,
      "postalCode": postalCode,
      "city": city,
    });

    var response = await http!.post(uri, headers: createHeaders(), body: body);

    if (response.statusCode != 200) {
      throw Exception("Failed to participate: ${response.body}");
    }
  }
}
