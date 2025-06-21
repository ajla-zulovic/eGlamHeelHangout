class AgeGroupReport {
  final String ageGroup;
  final int orderCount;

  AgeGroupReport({required this.ageGroup, required this.orderCount});

  factory AgeGroupReport.fromJson(Map<String, dynamic> json) {
    return AgeGroupReport(
      ageGroup: json['ageGroup'],
      orderCount: json['orderCount'],
    );
  }
}
