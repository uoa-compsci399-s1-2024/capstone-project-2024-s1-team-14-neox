class SingleYearDailyStatsModel{
  final int year;
  final Map<DateTime, Map<DateTime, int>> dailyStats;
  final Map<DateTime, double> monthlyMean;

  SingleYearDailyStatsModel({
    required this.year,
    required this.dailyStats,
    required this.monthlyMean,
  });

  @override
  String toString() {
  
    return "$monthlyMean";
  }
}
