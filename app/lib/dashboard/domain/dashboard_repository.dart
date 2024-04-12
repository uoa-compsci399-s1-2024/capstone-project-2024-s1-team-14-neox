import 'dart:math';

class DashboardRepository {
  static Map<int, Map<DateTime, int>> database = {};

  static void createRandomDataFromDate(int childId, DateTime date) {
    Random random = Random();
    if (!database.containsKey(childId)) {
      database[childId] = Map<DateTime, int>();
    }
    DateTime current_date = date;
    for (int i = 0; i < 60; i++) {
      database[childId]?[current_date] = random.nextInt(180);
      current_date = current_date.subtract(Duration(days: 1));
    }
  }

  static Map<DateTime, int> getDataForChildId(int childId) {
    if (database.containsKey(childId)) {
      return database[childId] as Map<DateTime, int>;
    }
    return {DateTime.now(): 0};
  }
}
