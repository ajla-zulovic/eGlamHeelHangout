import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../models/monthlyreport.dart';
import '../models/agereport.dart';
import '../providers/report_providers.dart';
import '../providers/base_providers.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _includeMonthlyRevenue = true;
  bool _includeAgeStats = true;

  List<MonthlyRevenueReport> _monthlyData = [];
  List<AgeGroupReport> _ageData = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      if (_includeMonthlyRevenue) {
        _monthlyData = await reportProvider.getMonthlyRevenueReport();
      }
      if (_includeAgeStats) {
        _ageData = await reportProvider.getOrderCountByAgeGroup();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: \$e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdf() async {
  try {
    final reportProvider = context.read<ReportProvider>();
    final bytes = await reportProvider.exportReportPdf(
      includeMonthlyRevenue: _includeMonthlyRevenue,
      includeAgeGroupStats: _includeAgeStats,
    );

    final dir = await getTemporaryDirectory();

    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  } on FileSystemException catch (e) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: ${e.osError?.message ?? e.message}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $e')), 
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Reports")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOptionsRow(),
                  const SizedBox(height: 20),
                  if ((_includeMonthlyRevenue && _monthlyData.isEmpty) &&
                    (_includeAgeStats && _ageData.isEmpty))
                  const Expanded(
                    child: Center(
                      child: Text(
                        "No reports available to display at this time.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (_includeMonthlyRevenue && _monthlyData.isNotEmpty) _buildMonthlyChart(),
                  if (_includeAgeStats && _ageData.isNotEmpty) _buildAgeChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        Checkbox(
          value: _includeMonthlyRevenue,
          onChanged: (value) => setState(() => _includeMonthlyRevenue = value!),
        ),
        const Text("Include Monthly Revenue"),
        const SizedBox(width: 20),
        Checkbox(
          value: _includeAgeStats,
          onChanged: (value) => setState(() => _includeAgeStats = value!),
        ),
        const Text("Include Age Group Stats"),
        const Spacer(),
       ElevatedButton.icon(
        onPressed: (_includeMonthlyRevenue && _monthlyData.isNotEmpty) ||
                    (_includeAgeStats && _ageData.isNotEmpty)
            ? _exportPdf
            : null, 
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Export PDF"),
      ),

      ],
    );
  }

  Widget _buildMonthlyChart() {
    return Expanded(
      child: SfCartesianChart(
        title: ChartTitle(text: 'Monthly Revenue'),
        primaryXAxis: CategoryAxis(),
       series: <CartesianSeries<dynamic, dynamic>>[
  ColumnSeries<MonthlyRevenueReport, String>(
    dataSource: _monthlyData,
    xValueMapper: (MonthlyRevenueReport r, _) => r.month,
    yValueMapper: (MonthlyRevenueReport r, _) => r.totalRevenue,
  )
]
      ),
    );
  }

  Widget _buildAgeChart() {
    return Expanded(
      child: SfCircularChart(
        title: ChartTitle(text: 'Orders by Age Group'),
        legend: Legend(isVisible: true),
        series: <CircularSeries<AgeGroupReport, String>>[
          PieSeries(
            dataSource: _ageData,
            xValueMapper: (AgeGroupReport a, _) => a.ageGroup,
            yValueMapper: (AgeGroupReport a, _) => a.orderCount,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }
}
