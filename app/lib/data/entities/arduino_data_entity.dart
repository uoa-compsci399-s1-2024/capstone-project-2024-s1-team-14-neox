import 'dart:math';
import 'dart:typed_data';
import 'package:capstone_project_2024_s1_team_14_neox/data/classifiers/light_gbm_small.dart';

import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;

import '../../server/child_data.dart';

@UseRowClass(ArduinoDataEntity)
class ArduinoDatas extends Table {
  // IntColumn get id => integer().autoIncrement()();

  IntColumn get childId =>
      integer().customConstraint('REFERENCES children(id) ON DELETE CASCADE')();

  IntColumn get uv => integer()();

  IntColumn get light => integer()();

  DateTimeColumn get datetime => dateTime()();

  IntColumn get accelX => integer()();

  IntColumn get accelY => integer()();

  IntColumn get accelZ => integer()();

  IntColumn get serverSynced => integer()();

  IntColumn get appClass => integer()();

  IntColumn get red => integer()();

  IntColumn get green => integer()();

  IntColumn get blue => integer()();

  IntColumn get clear => integer()();

  IntColumn get colourTemperature => integer()();

  @override
  Set<Column> get primaryKey => {childId, datetime};
}

class ArduinoDataEntity {
  String? name;
  int? uv;
  int? light;
  DateTime datetime;
  Int16List? accel;
  // int? id;
  int childId;
  int serverSynced;
  int appClass;
  int red;
  int green;
  int blue;
  int clear;
  int colourTemperature;

  ArduinoDataEntity(
      {this.name,
      this.uv,
      this.light,
      required this.datetime,
      this.accel,
      this.appClass = -1,
      this.serverSynced = 0,
      this.green = 0,
      this.blue = 0,
      this.red = 0,
      this.clear = 0,
      this.colourTemperature = 0,
      required this.childId});

  ArduinoDatasCompanion toCompanion() {
    return ArduinoDatasCompanion(
      uv: Value(uv ?? -1),
      light: Value(light ?? -1),
      datetime: Value(datetime),
      accelX: Value(accel?[0] ?? -1),
      accelY: Value(accel?[1] ?? -1),
      accelZ: Value(accel?[2] ?? -1),
      appClass: Value(appClass),
      serverSynced: Value(serverSynced),
      red: Value(red),
      blue: Value(blue),
      green: Value(green),
      childId: Value(childId),
      colourTemperature: Value(colourTemperature),
      clear: Value(clear),
    );
  }

  ChildData toChildData(String serverId) {
    return ChildData(
      accel_x: (accel != null && accel!.length > 0) ? accel![0] : -1,
      accel_y: (accel != null && accel!.length > 1) ? accel![1] : -1,
      accel_z: (accel != null && accel!.length > 2) ? accel![2] : -1,
      timestamp: datetime.toIso8601String(),
      childId: serverId,
      uv: uv!,
      light: light!,
      clear: clear,
      colourTemperature: colourTemperature,
      green: green,
      red: red,
      blue: blue,
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  // CREATE //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<void> saveSingleArduinoDataEntity(
      ArduinoDataEntity arduinoDataEntity) async {
    AppDb db = AppDb.instance();
    await db.into(db.arduinoDatas).insertOnConflictUpdate(
          arduinoDataEntity.toCompanion(),
        );
  }
  // 104 seconds to save 20160 samples
  // static Future<void> saveListOfArduinoDataEntity(
  //     List<ArduinoDataEntity> arduinoDataEntityList) async {
  //   await Future.forEach(arduinoDataEntityList, (arduinoDataEntity) async {
  //     await saveSingleArduinoDataEntity(arduinoDataEntity);
  //     // print("saved");
  //   });
  // }

  // Batch to speed up insertion
  // 1.017 seconds to save 20160 samples
  static Future<List<int>> saveListOfArduinoDataEntity(
      List<ArduinoDataEntity> arduinoDataEntityList) async {
    debugPrint("Classifying data samples, length: ${arduinoDataEntityList.length}");

    int outdoorMins = 0;
    int indoorMins = 0;

    for (ArduinoDataEntity sample in arduinoDataEntityList) {
      int appClass = ArduinoDataEntity.classifyArduinoDataEntity(sample);
      if (appClass == 0) {
        indoorMins += 1;
      } else {
        outdoorMins += 1;
      }

      sample.appClass = appClass;
    }

    AppDb db = AppDb.instance();

    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
          db.arduinoDatas, arduinoDataEntityList.map((e) => e.toCompanion()));
    });
    debugPrint("$outdoorMins outdoors, $indoorMins indoors");
    return [outdoorMins, indoorMins];
  }

  // batch for updating local if timestamp exists
  // static Future<void> saveListOfArduinoDataEntity(
  //     List<ArduinoDataEntity> arduinoDataEntityList) async {
  //   AppDb db = AppDb.instance();

  //   await db.batch((batch) {
  //     for (ArduinoDataEntity e in arduinoDataEntityList) {
  //       batch.insert(db.arduinoDatas, e.toCompanion(),
  //           onConflict: DoUpdate((old) => e.toCompanion(),
  //               target: [db.arduinoDatas.childId, db.arduinoDatas.datetime]));
  //     }
  //   });
  // }
  ////////////////////////////////////////////////////////////////////////////
  // READ ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<List<ArduinoDataEntity>> queryAllArduinoData() async {
    AppDb db = AppDb.instance();
    List<ArduinoDataEntity> arduinoDataEntityList =
        await db.select(db.arduinoDatas).get();
    return arduinoDataEntityList;
  }

  static Future<List<ArduinoDataEntity>> queryArduinoDataById(
      int childId) async {
    final db = AppDb.instance();
    final query = db.select(db.arduinoDatas)
      ..where((tbl) => tbl.childId.equals(childId));
    return query.get();
  }

  static Future<List<ArduinoDataEntity>> queryListOfArduinoDataByUVLevel(
      int uvLevel) async {
    AppDb db = AppDb.instance();
    List<ArduinoDataEntity> arduinoDataEntityList =
        await (db.select(db.arduinoDatas)
              ..where((tbl) => tbl.uv.equals(uvLevel)))
            .get();
    return arduinoDataEntityList;
  }

  static Future<Map<DateTime, int>> getDailyOutdoorMinutesForChildId(
      int childId) async {
    AppDb db = AppDb.instance();
    List<ArduinoDataEntity> entityList = await (db.select(db.arduinoDatas)
          ..where((tbl) => tbl.childId.equals(childId))
          ..where((tbl) => tbl.appClass.equals(1)))
        .get();
    return {DateTime.now(): entityList.length};
  }

  // Function to get the oldest datetime from the database
  static Future<DateTime?> getOldestDateTime() async {
    final db = AppDb.instance();
    final query = await (db.select(db.arduinoDatas)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.datetime, mode: OrderingMode.asc)
      ])
      ..limit(1));

    final result = await query.getSingleOrNull();
    return result?.datetime;
  }

// Function to get the newest datetime from the database
  static Future<DateTime?> getNewestDateTime() async {
    final db = AppDb.instance();
    final query = await (db.select(db.arduinoDatas)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.datetime, mode: OrderingMode.desc)
      ])
      ..limit(1));

    final result = await query.getSingleOrNull();
    return result?.datetime;
  }
  ////////////////////////////////////////////////////////////////////////////
  // UPDATE //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  // static Future<void> updateAppClass(int id, int appClass) async {
  //   final db = AppDb.instance();
  //   await (db.update(db.arduinoDatas)..where((tbl) => tbl.id.equals(id)))
  //       .write(ArduinoDatasCompanion(appClass: Value(appClass)));
  // }

  ////////////////////////////////////////////////////////////////////////////
  // GRAPHS //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<List<ArduinoDataEntity>> queryArduinoDataForChildByDateRange(
      DateTime startDate, DateTime endDate, int childId) async {
    final db = AppDb.instance();
    final query = db.select(db.arduinoDatas)
      ..where((tbl) => tbl.childId.equals(childId))
      ..where((tbl) => tbl.datetime.isBetweenValues(startDate, endDate));

    return query.get();
  }

  static Future<int> getOutdoorCountForChildByDateRange(
      DateTime startDate, DateTime endDate, int childId) async {
    List<ArduinoDataEntity> query =
        await queryArduinoDataForChildByDateRange(startDate, endDate, childId);
    return countSamplesWithAppClass1(query);
  }

  static int countSamplesWithAppClass1(List<ArduinoDataEntity> dataList) {
    return dataList.where((data) => data.appClass == 1).length;
  }

  static Future<Map<DateTime, int>> countSamplesByDay(
      DateTime startTime, DateTime endTime, int childId) async {
    final Map<DateTime, int> result = {};

    for (var day = startTime;
        day.isBefore(endTime);
        day = day.add(const Duration(days: 1))) {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      final dataList = await queryArduinoDataForChildByDateRange(
          startOfDay, endOfDay, childId);

      result[startOfDay] = countSamplesWithAppClass1(dataList);
    }

    return result;
  }

  static Future<Map<DateTime, int>> countSamplesByHour(
      DateTime startTime, DateTime endTime, int childId) async {
    final Map<DateTime, int> result = {};

    for (var hour = startTime;
        hour.isBefore(endTime);
        hour = hour.add(const Duration(hours: 1))) {
      final startOfHour = DateTime(hour.year, hour.month, hour.day, hour.hour);
      final endOfHour = startOfHour
          .add(const Duration(hours: 1))
          .subtract(Duration(seconds: 1));

      final dataList = await queryArduinoDataForChildByDateRange(
          startOfHour, endOfHour, childId);

      result[startOfHour] = countSamplesWithAppClass1(dataList);
    }

    return result;
  }

  static Future<Map<DateTime, Map<DateTime, int>>> getSingleYearDailyStats(
      int year, int childId) async {
    // Generate map
    Map<DateTime, Map<DateTime, int>> dailyStats = {};
    for (int month = 1; month <= 12; month += 1) {
      int daysInMonth = material.DateUtils.getDaysInMonth(year, month);
      Map<DateTime, int> monthly = {};
      for (int day = 1; day <= daysInMonth; day += 1) {
        monthly[DateTime(year, month, day)] = 0;
      }
      dailyStats[DateTime(year, month, 1)] = monthly;
    }
    // Query Database
    final db = AppDb.instance();
    final query = db.select(db.arduinoDatas)
      ..where((tbl) => tbl.childId.equals(childId))
      ..where((tbl) => tbl.datetime.isBetweenValues(
          DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59)))
      ..where((tbl) => tbl.appClass.equals(1));
    List<ArduinoDataEntity> dataList = await query.get();
    for (ArduinoDataEntity sample in dataList) {
      int year = sample.datetime.year;
      int month = sample.datetime.month;
      int day = sample.datetime.day;
      dailyStats[DateTime(year, month, 1)]![DateTime(year, month, day)] =
          (dailyStats[DateTime(year, month, 1)]![DateTime(year, month, day)] ??
                  0) +
              1;
    }
    return dailyStats;
  }

  static Future<Map<DateTime, Map<DateTime, int>>> getSingleWeekHourlyStats(
      DateTime startMonday, int childId) async {
    startMonday =
        DateTime(startMonday.year, startMonday.month, startMonday.day);
    // Generate map
    Map<DateTime, Map<DateTime, int>> hourlyStats = {};
    for (int dayOffset = 0; dayOffset <= 6; dayOffset += 1) {
      DateTime currentDay = startMonday.add(Duration(days: dayOffset));
      //Dailylight savings
      currentDay = DateTime(currentDay.year, currentDay.month, currentDay.day);

      Map<DateTime, int> daily = {};
      for (int hour = 0; hour < 24; hour += 1) {
        daily[currentDay.add(Duration(hours: hour))] = 0;
      }
      hourlyStats[currentDay] = daily;
    }
    // Query Database
    final db = AppDb.instance();
    final query = db.select(db.arduinoDatas)
      ..where((tbl) => tbl.childId.equals(childId))
      ..where((tbl) => tbl.datetime.isBetweenValues(
          startMonday,
          startMonday
              .add(const Duration(days: 7))
              .subtract(const Duration(seconds: 1))))
      ..where((tbl) => tbl.appClass.equals(1));
    List<ArduinoDataEntity> dataList = await query.get();
    for (ArduinoDataEntity sample in dataList) {
      int year = sample.datetime.year;
      int month = sample.datetime.month;
      int day = sample.datetime.day;
      int hour = sample.datetime.hour;
      hourlyStats[DateTime(year, month, day)]![
              DateTime(year, month, day, hour)] =
          (hourlyStats[DateTime(year, month, day)]![
                      DateTime(year, month, day, hour)] ??
                  0) +
              1;
    }
    return hourlyStats;
  }

  ////////////////////////////////////////////////////////////////////////////
  // CLASSIFICATION //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static int classifyArduinoDataEntity(ArduinoDataEntity sample) {
    int uv = sample.uv ?? 1;

    int accelX = sample.accel![0];
    int accelY = sample.accel![1];
    int accelZ = sample.accel![2];
    int red = sample.red;
    int green = sample.green;
    int blue = sample.blue;
    int clear = sample.clear;
    int colourTemperature = sample.colourTemperature;
    int light = sample.light ?? 1;

    List<double> features = [];
    features.addAll([
      uv.toDouble(),
      accelX.toDouble(),
      accelY.toDouble(),
      accelZ.toDouble(),
      red.toDouble(),
      green.toDouble(),
      blue.toDouble(),
      clear.toDouble(),
      colourTemperature.toDouble(),
      light.toDouble(),
    ]);

    // acceleration

    features.add((accelX + accelY + accelZ).toDouble());
    features.add((pow(accelX, 2) + pow(accelY, 2) + pow(accelZ, 2)).toDouble());
    features.add((accelX * accelY).abs().toDouble());

    // rgb vs clear
    features.add(red / (clear + 1));
    features.add(green / (clear + 1));
    features.add(blue / (clear + 1));

    features.add(red / (green + 1));
    features.add(blue / (red + 1));
    features.add(blue / (green + 1));

    features.add((clear - red) / (red + 1));
    features.add((clear - green) / (red + 1));
    features.add((clear - blue) / (red + 1));

    features.add((clear - red) / (green + 1));
    features.add((clear - green) / (green + 1));
    features.add((clear - blue) / (green + 1));

    features.add((clear - red) / (blue + 1));
    features.add((clear - green) / (blue + 1));
    features.add((clear - blue) / (blue + 1));

    features.add((clear - red) / (clear + 1));
    features.add((clear - green) / (clear + 1));
    features.add((clear - blue) / (clear + 1));

    // log
    double redLog = log(red + 1);
    double greenLog = log(green + 1);
    double blueLog = log(blue + 1);
    double clearLog = log(clear + 1);

    features.add(redLog / clearLog);
    features.add(greenLog / clearLog);
    features.add(blueLog / clearLog);

    features.add(redLog / (greenLog + 1));
    features.add(blueLog / (redLog + 1));
    features.add(blueLog / (greenLog + 1));

// squre root
    double redSqrt = sqrt(red + 1);
    double greenSqrt = sqrt(green + 1);
    double blueSqrt = sqrt(blue + 1);
    double clearSqrt = sqrt(clear + 1);

    features.add(redSqrt / clearSqrt);
    features.add(greenSqrt / clearSqrt);
    features.add(blueSqrt / clearSqrt);

    features.add(redSqrt / (greenSqrt + 1));
    features.add(blueSqrt / (redSqrt + 1));
    features.add(blueSqrt / (greenSqrt + 1));

    // uv vs lux
    double lightLog = log(light + 1);
    double uvLog = log(uv + 2);
    double lightSqrt = sqrt(light + 1);
    double uvSqrt = sqrt(uv + 1);

    features.add(light / (uv + 1));
    features.add(blue / (uv + 1));
    features.add((clear - blue) / (uv + 1));
    features.add(lightLog / uvLog);
    features.add(blueLog / uvLog);
    features.add(lightSqrt / uvSqrt);
    features.add(blueSqrt / uvSqrt);
    List<double> probabilities = score(features);
// print("$uv $light $probabilities");
    return probabilities[1] > 0.50 ? 1 : 0;
  }

///////////////////////////////////////////////////////////////////
// FOR TESTING PURPOSE DELETE LATER //////////////////////////////
//////////////////////////////////////////////////////////////////

  static Future<List<ArduinoDataEntity>> createSampleArduinoDataList(
      int childId,
      DateTime startTime,
      DateTime endTime,
      double threshold) async {
    List<ArduinoDataEntity> dataList = [];
    Random random = Random();
    int interval = 1; //Default 1 minute
    for (DateTime time = startTime;
        time.isBefore(endTime);
        time = time.add(Duration(minutes: interval))) {
      if (time.hour > 5 && time.hour < 22) {
        // only add if between 6am and 10pm
        final data = ArduinoDataEntity(
          uv: 100,
          light: 35000,
          red: 200,
          green: 200,
          blue: 200,
          clear: 200,
          colourTemperature: 0,
          datetime: time,
          accel: Int16List.fromList([33, 44, 55]),
          serverSynced: 0,
          appClass: 0, // Generates either 0 or 1 randomly
          childId: childId,
        );
        dataList.add(data);
      }
    }
    return dataList;
  }
}
