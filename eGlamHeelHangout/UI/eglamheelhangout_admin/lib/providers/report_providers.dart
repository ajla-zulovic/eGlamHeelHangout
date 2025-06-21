import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/monthlyreport.dart';
import '../models/agereport.dart';
import '../providers/base_providers.dart';

class ReportProvider extends BaseProvider<dynamic> {
  ReportProvider() : super("Report");

  Future<List<MonthlyRevenueReport>> getMonthlyRevenueReport() async {
    var uri = Uri.parse("$baseUrl$endpoint/monthly-revenue");
    var response = await http.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => MonthlyRevenueReport.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load revenue report');
    }
  }

  Future<List<AgeGroupReport>> getOrderCountByAgeGroup() async {
    var uri = Uri.parse("$baseUrl$endpoint/order-count-by-age-group");
    var response = await http.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => AgeGroupReport.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load age group report');
    }
  }

  Future<Uint8List> exportReportPdf({
    required bool includeMonthlyRevenue,
    required bool includeAgeGroupStats,
  }) async {
    var uri = Uri.parse("$baseUrl$endpoint/export/pdf");
    var response = await http.post(
      uri,
      headers: {
        ...createHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'includeMonthlyRevenue': includeMonthlyRevenue,
        'includeAgeGroupStats': includeAgeGroupStats,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to generate PDF report');
    }
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return {};
  }
}
