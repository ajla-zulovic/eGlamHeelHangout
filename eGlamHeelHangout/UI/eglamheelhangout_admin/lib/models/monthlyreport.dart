class MonthlyRevenueReport {
  final String month;
  final double totalRevenue;

  MonthlyRevenueReport({required this.month, required this.totalRevenue});

  factory MonthlyRevenueReport.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueReport(
      month: json['month'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }
}
