import 'dart:math';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/entities/arduino_data_entity.dart';

class StatisticsRepository {
  final SharedPreferences sharedPreferences;
  StatisticsRepository({required this.sharedPreferences});
  final Map<DateTime, SingleWeekHourlyStatsModel> _weekCache = {};
  final Map<int, SingleYearDailyStatsModel> _yearCache = {};

  int? getFocusChildId() {
    return sharedPreferences.getInt("focus_id");
  }

  Future<void> updateFocusChildId(int childId) async {
    await sharedPreferences.setInt("focus_id", childId);
  }

  int getDailyTarget() {
    return sharedPreferences.getInt("daily_target")!;
  }

  void deleteCache() {
    _weekCache.clear();
    _yearCache.clear();
  }

  // Daily UI
  Future<List<SingleWeekHourlyStatsModel>> getListOfHourlyStats(
      DateTime startMonday, int weekCount, int childId) async {
    List<SingleWeekHourlyStatsModel> result = [];

    for (int i = 0; i < weekCount; i++) {
      DateTime currentMonday = startMonday.subtract(Duration(days: 7 * i));
      DateTime currentMondayMidnight =
          DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
      SingleWeekHourlyStatsModel week = _weekCache[currentMondayMidnight] ??
          await getSingleWeekHourlyStats(currentMonday, childId);
      result.add(week);
    }
    return result;
  }

  Future<SingleWeekHourlyStatsModel> getSingleWeekHourlyStats(
      DateTime startMonday, int childId) async {
    Map<DateTime, int> dailySum = {};
    double weeklyMean = 0;

    Map<DateTime, Map<DateTime, int>> hourlyStats =
        await ArduinoDataEntity.getSingleWeekHourlyStats(startMonday, childId);

    hourlyStats.forEach((key, value) {
      dailySum[key] = value.values.reduce((value, element) => value + element);
    });

    int elaspsedDays =
        min(max(DateTime.now().difference(startMonday).inDays, 1), 7);
    weeklyMean = dailySum.values.reduce((value, element) => value + element) /
        elaspsedDays;

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
    int dailyTarget = getDailyTarget();
    if (!_yearCache.containsKey(year)) {
      Map<DateTime, double> monthlyMean = {};
      Map<DateTime, int> monthlyTargetAcheived = {};
      DateTime currentTime = DateTime.now();

      Map<DateTime, Map<DateTime, int>> dailyStats =
          await ArduinoDataEntity.getSingleYearDailyStats(year, childId);
      // for each Map<startMonday, Map<day, dailyOutdoorTime>>)

      dailyStats.forEach((startMonth, monthlyOutdoorTime) {
        int elaspsedDays = 0;
        int totalOutdoorTime = 0;
        int targetAcheivedCount = 0;

        monthlyOutdoorTime.forEach((day, outdoorTime) {
          if (day.isBefore(currentTime)) {
            elaspsedDays += 1;
          }
          if (outdoorTime >= dailyTarget) {
            targetAcheivedCount += 1;
          }
          totalOutdoorTime += outdoorTime;
        });

        monthlyMean[startMonth] =
            elaspsedDays == 0 ? 0 : totalOutdoorTime / elaspsedDays;
        monthlyTargetAcheived[startMonth] = targetAcheivedCount;
      });
      _yearCache[year] = SingleYearDailyStatsModel(
        year: year,
        dailyStats: dailyStats,
        monthlyMean: monthlyMean,
        monthlyTargetAcheived: monthlyTargetAcheived,
      );
    }
    return _yearCache[year]!;
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
    return await ArduinoDataEntity.countSamplesByDay(
        getMostRecentMonday(), DateTime.now(), childId);
  }

  static DateTime getMostRecentMonday() {
    final today = DateTime.now();
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    return today.subtract(Duration(days: daysSinceMonday));
  }

  Future<int> getOutdoorTimeForPastDays(int childId, int daysBack) async {
    DateTime current = DateTime.now();

    DateTime startDate = DateTime(current.year, current.month, current.day)
        .subtract(Duration(days: daysBack - 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day);

    DateTime endDate =
        DateTime(current.year, current.month, current.day, 23, 59, 59);
    return await ArduinoDataEntity.getOutdoorCountForChildByDateRange(
        startDate, endDate, childId);
  }
  // Caclulate total minutes per day
  // Calculate total minutes per hour between 00:00 to 24:59
}
