class SingleWeekHourlyStatsModel {
  final DateTime startMondayDate;
  final Map<DateTime, Map<DateTime, int>> hourlyStats;
  final Map<DateTime, int> dailySum;
  final double weeklyMean;

  SingleWeekHourlyStatsModel({
    required this.startMondayDate,
    required this.hourlyStats,
    required this.dailySum,
    required this.weeklyMean,
  });

  @override
  String toString() {
  
    return "$startMondayDate $hourlyStats $weeklyMean";
  }
}
