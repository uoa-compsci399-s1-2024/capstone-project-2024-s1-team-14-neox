import 'dart:math';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:path/path.dart';

import '../../data/entities/arduino_data_entity.dart';

class StatisticsRepository {
  
  // Daily UI
  Future<List<SingleWeekHourlyStatsModel>> getListOfHourlyStats(
      DateTime startMonday, int weekCount, int childId) async {
    List<SingleWeekHourlyStatsModel> result = [];

    for (int i = 0; i < weekCount; i++) {
      DateTime currentMonday = startMonday.subtract(Duration(days: 7 * i));
      result.add(await getSingleWeekHourlyStats(currentMonday, childId));
    }
    // print(result);
    return result;
  }

  Future<SingleWeekHourlyStatsModel> getSingleWeekHourlyStats(
      DateTime startMonday, int childId) async {
    Map<DateTime, int> dailySum = {};
    double weeklyMean = 0;

    Map<DateTime, Map<DateTime, int>> hourlyStats = await ArduinoDataEntity.getSingleWeekHourlyStats(startMonday, childId);

    hourlyStats.forEach((key, value) {
      dailySum[key] = value.values.reduce((value, element) => value + element);
     });

     int elaspsedDays = min(max(DateTime.now().difference(startMonday).inDays, 1), 7);
     weeklyMean = dailySum.values.reduce((value, element) => value + element) / elaspsedDays;


    return SingleWeekHourlyStatsModel(
      startMondayDate: startMonday,
      hourlyStats: hourlyStats,
      dailySum: dailySum,
      weeklyMean: weeklyMean,
    );
  }

  // Weekly UI

  // Monthly UI
  Future<SingleYearDailyStatsModel> getSingleYearDailyStats(
      int year, int childId) async {
    Map<DateTime, double> monthlyMean = {};

    Map<DateTime, Map<DateTime, int>> dailyStats = await ArduinoDataEntity.getSingleYearDailyStats(year, childId);

    dailyStats.forEach((key, value) {
      int elaspsedDays = min(max(DateTime.now().difference(key).inDays, 1), value.length);
      monthlyMean[key] = value.values.reduce((value, element) => value + element) / elaspsedDays;
     });
    return SingleYearDailyStatsModel(
      year: year,
      dailyStats: dailyStats,
      monthlyMean: monthlyMean,
    );
  }





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
