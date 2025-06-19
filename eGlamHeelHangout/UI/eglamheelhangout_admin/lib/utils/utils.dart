import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';



class Authorization{
    static String? username;
    static String? password;
}


String formatNumber(dynamic value) {
  if (value == null) {
    return "";
  }
  
  final format = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  return format.format(value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0);
}


Image imageFromBase64String(String? base64String) {
  try {
    if (base64String == null || base64String.isEmpty) {
      throw Exception("Empty image data");
    }

    return Image.memory(base64Decode(base64String));
  } catch (e) {
    debugPrint("Invalid image data: $e");
    return Image.asset('assets/images/images.png');
  }
}


Widget imageFromBase64StringFormat(String base64String,
    {double width = 120, double height = 120, double radius = 10}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      width: width,
      height: height,
      child: Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover, 
      ),
    ),
  );
}