import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../models/paymentcreate.dart'; 

class PaymentService {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(PaymentCreate paymentData) async {
    try {
      // 1. Poziv backendu da kreira PaymentIntent
      final response = await http.post(
       // Uri.parse('https://10.0.2.2:7277/Stripe/create-intent'),
       Uri.parse('https://localhost:7277/Stripe/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Greška pri kreiranju PaymentIntent-a');
      }

      final jsonResponse = jsonDecode(response.body);
      paymentIntentData = jsonResponse;

      // 2. Inicijalizuj Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['clientSecret'],
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
