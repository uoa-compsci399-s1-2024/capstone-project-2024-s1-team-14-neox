import 'dart:math';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:path/path.dart';

import '../../data/entities/arduino_data_entity.dart';

class StatisticsRepository {
  // Daily UI
  Future<List<SingleWeekHourlyStatsModel>> getListOfHourlyStats(
      DateTime startMonday, int weekCount, int childId) async {
    List<SingleWeekHourlyStatsModel> result = [];

    for (int i = 0; i < weekCount; i++) {
      DateTime currentMonday = startMonday.subtract(Duration(days: 7 * i));
      result.add(await getSingleWeekDailyStats(currentMonday, childId));
    }
    return result;
  }

  Future<SingleWeekHourlyStatsModel> getSingleWeekDailyStats(
      DateTime startMonday, int childId) async {
    Map<DateTime, Map<DateTime, int>> dailyStats = {};
    Map<DateTime, int> dailySum = {};

    for (int weekday = 0; weekday < 7; weekday++) {
      DateTime currentDay = startMonday.add(Duration(days: weekday));
      Map<DateTime, int> hourlyStats =
          await ArduinoDataEntity.countSamplesByHour(
              currentDay, currentDay.add(const Duration(days: 1)), childId);

      dailyStats[currentDay] = hourlyStats;
      dailySum[currentDay] =
          hourlyStats.values.reduce((value, element) => value + element);
    }
    return SingleWeekHourlyStatsModel(
      startMondayDate: startMonday,
      dailyStats: dailyStats,
      dailySum: dailySum,
    );
  }

  // Weekly UI

  // TODO Delete static functions
  static Map<int, Map<DateTime, int>> database = {};

  static void createRandomDataFromDate(int childId, DateTime date) {
    Random random = Random();
    if (!database.containsKey(childId)) {
      database[childId] = Map<DateTime, int>();
    }
    DateTime current_date = date;
    for (int i = 0; i < 30; i++) {
      database[childId]?[current_date] = random.nextInt(130);
      current_date = current_date.subtract(Duration(days: 1));
    }
  }

  static Map<DateTime, int> getFalseDataForChildId(int childId) {
    if (database.containsKey(childId)) {
      return database[childId] as Map<DateTime, int>;
    }
    return {DateTime.now(): 0};
  }

  static Future<Map<DateTime, int>> getWeeklyOutdoorMinutes(int childId) async {
    return await ArduinoDataEntity.countSamplesByDay(getMostRecentMonday() ,DateTime.now() , childId);
  }

  static DateTime getMostRecentMonday() {
    final today = DateTime.now();
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    return today.subtract(Duration(days: daysSinceMonday));
  }

  // TODO
  // Caclulate total minutes per day
  // Calculate total minutes per hour between 00:00 to 24:59
}
