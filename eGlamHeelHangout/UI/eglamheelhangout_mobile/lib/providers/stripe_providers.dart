import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeProvider with ChangeNotifier {
  bool _initialized = false;
  String? _publishableKey;

  bool get isInitialized => _initialized;
  String? get publishableKey => _publishableKey;

  Future<void> initializeStripe() async {
    try {
    //final response = await http.get(Uri.parse('https://10.0.2.2:7277/Stripe/config'));
    final response = await http.get(Uri.parse('https://localhost:7277/Stripe/config'));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final key = data['publishableKey'];

        if (key != null && key.toString().isNotEmpty) {
          Stripe.publishableKey = key;
          await Stripe.instance.applySettings();
          _publishableKey = key;
          _initialized = true;
          notifyListeners();
        } else {
          throw Exception('Publishable key is null or empty.');
        }
      } else {
        throw Exception('Failed to fetch Stripe key from backend. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Stripe init error: $e');
      rethrow;
    }
  }
}
