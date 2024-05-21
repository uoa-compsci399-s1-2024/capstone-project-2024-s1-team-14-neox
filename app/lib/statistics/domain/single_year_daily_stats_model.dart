class SingleYearDailyStatsModel{
  final int year;
  final Map<DateTime, Map<DateTime, int>> monthlyStats;
  final Map<DateTime, double> monthlyMean;

  SingleYearDailyStatsModel({
    required this.year,
    required this.monthlyStats,
    required this.monthlyMean,
  });

  @override
  String toString() {
  
    return monthlyStats.toString() + monthlyMean.toString();
  }
}
