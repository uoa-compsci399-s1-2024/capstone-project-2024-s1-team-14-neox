class SingleYearDailyStatsModel {
  final int year;
  final Map<DateTime, Map<DateTime, int>> dailyStats;
  final Map<DateTime, double> monthlyMean;
  final Map<DateTime, int> monthlyTargetAcheived;

  SingleYearDailyStatsModel({
    required this.year,
    required this.dailyStats,
    required this.monthlyMean,
    required this.monthlyTargetAcheived,
  });

  @override
  String toString() {
    return "$monthlyMean";
  }
}
