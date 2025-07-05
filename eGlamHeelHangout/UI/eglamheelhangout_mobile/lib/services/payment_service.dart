import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../models/paymentcreate.dart';

class PaymentService {
  Map<String, dynamic>? paymentIntentData;


  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:7277',
  );

  Future<void> makePayment(PaymentCreate paymentData) async {
    try {
     
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final url = Uri.parse('$cleanBase/Stripe/create-intent');
      print(">>> Payment URL: $url");

    
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData.toJson()),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Greška pri kreiranju PaymentIntent-a');
      }

    
      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      if (clientSecret == null || clientSecret.toString().isEmpty) {
        throw Exception("Stripe clientSecret je null ili prazan.");
      }

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

      await Stripe.instance.presentPaymentSheet();

      print('Payment successful!');
    } catch (e) {
      print('Payment error: $e');
    }
  }
}
