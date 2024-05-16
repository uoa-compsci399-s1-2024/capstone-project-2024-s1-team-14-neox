class SingleWeekHourlyStatsModel {
  final DateTime startMondayDate;
  final Map<DateTime, Map<DateTime, int>> dailyStats;
  final Map<DateTime, int> dailySum;

  SingleWeekHourlyStatsModel({
    required this.startMondayDate,
    required this.dailyStats,
    required this.dailySum,
  });
}
