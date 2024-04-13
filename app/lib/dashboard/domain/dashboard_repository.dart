import 'dart:math';

class DashboardRepository {
  static Map<int, Map<DateTime, int>> database = {};

  static void createRandomDataFromDate(int childId, DateTime date) {
    Random random = Random();
    if (!database.containsKey(childId)) {
      database[childId] = Map<DateTime, int>();
    }
    DateTime current_date = date;
    for (int i = 0; i < 30; i++) {
      database[childId]?[current_date] = random.nextInt(180);
      current_date = current_date.subtract(Duration(days: 1));
    }
    print(database[childId]);
  }

  static Map<DateTime, int> getDataForChildId(int childId) {
    print("The child id is $childId");
    if (database.containsKey(childId)) {
      return database[childId] as Map<DateTime, int>;
    }
    return {DateTime.now(): 0};
  }


  // TODO
  // Caclulate total minutes per day
  // Calculate total minutes per hour between 00:00 to 24:59


}
