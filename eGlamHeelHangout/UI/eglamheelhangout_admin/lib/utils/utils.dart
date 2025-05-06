import 'package:intl/intl.dart';
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