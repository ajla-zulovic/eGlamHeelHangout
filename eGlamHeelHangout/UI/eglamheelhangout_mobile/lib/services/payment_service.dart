import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../models/paymentcreate.dart';

class PaymentService {
  Map<String, dynamic>? paymentIntentData;
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:7277');
  Future<void> makePayment(PaymentCreate paymentData) async {
    try {
      // 1. Poziv backendu da kreira PaymentIntent
    final response = await http.post(
      Uri.parse('$baseUrl/Stripe/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData.toJson()),
      );
      

      if (response.statusCode != 200) {
        throw Exception('Greška pri kreiranju PaymentIntent-a');
      }

      final jsonResponse = jsonDecode(response.body);
      print('Stripe create-intent response: $jsonResponse');

      paymentIntentData = jsonResponse;
      final clientSecret = paymentIntentData?['clientSecret'];

      if (clientSecret == null || clientSecret.toString().isEmpty) {
        throw Exception("Stripe clientSecret je null ili prazan.");
      }

      // 2. Inicijalizuj Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Glam Heel Hangout',
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'BA',
            testEnv: true,
          ),
        ),
      );

      // 3. Prikazivanje plaćanja
      await Stripe.instance.presentPaymentSheet();

      print('Payment successful!');
    } catch (e) {
      print('Payment error: $e');
    }
  }
}
