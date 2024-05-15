import 'dart:math';
import '../../data/entities/arduino_data_entity.dart';

class StatisticsRepository {
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

  static Future<Map<DateTime, int>> getDailyOutdoorMinutes(int childId) async {
    return await ArduinoDataEntity.getDailyOutdoorMinutesForChildId(childId);
  }

  // TODO
  // Caclulate total minutes per day
  // Calculate total minutes per hour between 00:00 to 24:59


}
