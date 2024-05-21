import 'dart:ffi';
import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';

import '../../server/child_data.dart';
import 'child_entity.dart';
import 'dart:math';

@UseRowClass(ArduinoDataEntity)
class ArduinoDatas extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get childId =>
      integer().customConstraint('REFERENCES children(id) ON DELETE CASCADE')();

  IntColumn get uv => integer()();

  IntColumn get light => integer()();

  DateTimeColumn get datetime => dateTime()();

  IntColumn get accelX => integer()();

  IntColumn get accelY => integer()();

  IntColumn get accelZ => integer()();

  IntColumn get serverClass => integer()();

  IntColumn get appClass => integer()();

  IntColumn get red => integer()();

  IntColumn get green => integer()();

  IntColumn get blue => integer()();

  IntColumn get clear => integer()();

  IntColumn get colourTemperature => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArduinoDataEntity {
  String? name;
  int? uv;
  int? light;
  DateTime datetime;
  Int16List? accel;
  int? id;
  int childId;
  int serverClass;
  int appClass;
  int red;
  int green;
  int blue;
  int clear;
  int colourTemperature;

  ArduinoDataEntity(
      {this.id,
      this.name,
      this.uv,
      this.light,
      required this.datetime,
      this.accel,
      this.appClass = -1,
      this.serverClass = -1,
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
      serverClass: Value(serverClass),
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
    await db
        .into(db.arduinoDatas)
        .insertOnConflictUpdate(arduinoDataEntity.toCompanion());
  }

  static Future<void> saveListOfArduinoDataEntity(
      List<ArduinoDataEntity> arduinoDataEntityList) async {
    await Future.forEach(arduinoDataEntityList, (arduinoDataEntity) async {
      await saveSingleArduinoDataEntity(arduinoDataEntity);
    });
  }

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
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.datetime, mode: OrderingMode.asc)])
      ..limit(1));

    final result = await query.getSingleOrNull();
    return result?.datetime;
  }

// Function to get the newest datetime from the database
  static Future<DateTime?> getNewestDateTime() async {
    final db = AppDb.instance();
    final query = await (db.select(db.arduinoDatas)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.datetime, mode: OrderingMode.desc)])
      ..limit(1));

    final result = await query.getSingleOrNull();
    return result?.datetime;
  }
  ////////////////////////////////////////////////////////////////////////////
  // UPDATE //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<void> updateAppClass(int id, int appClass) async {
    final db = AppDb.instance();
    await (db.update(db.arduinoDatas)..where((tbl) => tbl.id.equals(id)))
        .write(ArduinoDatasCompanion(appClass: Value(appClass)));
  }

  static Future<void> updateServerClass(int id, int serverClass) async {
    final db = AppDb.instance();
    await (db.update(db.arduinoDatas)..where((tbl) => tbl.id.equals(id)))
        .write(ArduinoDatasCompanion(serverClass: Value(serverClass)));
  }

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

  static int countSamplesWithAppClass1(List<ArduinoDataEntity> dataList) {
    return dataList.where((data) => data.appClass == 1).length;
  }

  static Future<Map<DateTime, int>> countSamplesByDay(
      DateTime startTime, DateTime endTime, int childId) async {
    final Map<DateTime, int> result = {};

    for (var day = startTime;
        day.isBefore(endTime);
        day = day.add(Duration(days: 1))) {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay =
          startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

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
        hour = hour.add(Duration(hours: 1))) {
      final startOfHour = DateTime(hour.year, hour.month, hour.day, hour.hour);
      final endOfHour =
          startOfHour.add(Duration(hours: 1)).subtract(Duration(seconds: 1));

      final dataList = await queryArduinoDataForChildByDateRange(
          startOfHour, endOfHour, childId);

      result[startOfHour] = countSamplesWithAppClass1(dataList);
    }

    return result;
  }

///////////////////////////////////////////////////////////////////
// FOR TESTING PURPOSE DELETE LATER //////////////////////////////
//////////////////////////////////////////////////////////////////

  static Future<List<ArduinoDataEntity>> createSampleArduinoDataList(
      int childId, DateTime startDate, int requiredDays) async {
    final List<ArduinoDataEntity> dataList = [];

    // Sample data for testing
    DateTime dateTime = DateTime.now().subtract(Duration(days: requiredDays));
    Random random = Random();
    for (int i = 0; i < requiredDays * 24 * 60 / 5 - 1; i += 5) {
      // Increment datetime by 1 minute
      dateTime = dateTime.add(Duration(minutes: 5));

      final data = ArduinoDataEntity(
        uv: 5,
        light: 100,
        datetime: dateTime,
        accel: Int16List.fromList([1, 2, 3]),
        serverClass: 1,
        appClass: random.nextDouble() < 0.5 ? 0 : 1, // Generates either 0 or 1 randomly
        childId: childId,
      );
      dataList.add(data);
    }

    return dataList;
  }
}
