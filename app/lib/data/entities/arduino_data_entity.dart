import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';

import 'child_entity.dart';

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

  ArduinoDataEntity(
      {this.id,
      this.name,
      this.uv,
      this.light,
      required this.datetime,
      this.accel,
      this.appClass = -1,
      this.serverClass = -1,
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
        childId: Value(childId));
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
      ..where((tbl) => tbl.id.equals(childId));
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
          ..where((tbl) => tbl.appClass.equals(1))
          )
        .get();
    return {DateTime.now() : entityList.length};
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

///////////////////////////////////////////////////////////////////
// FOR TESTING PURPOSE DELETE LATER //////////////////////////////
//////////////////////////////////////////////////////////////////

// static Future<List<ArduinoDataEntity>> createSampleArduinoDataList(
//     int childId) async {
//   final List<ArduinoDataEntity> dataList = [];
//
//   // Sample data for testing
//   for (int i = 0; i < 10; i++) {
//     final data = ArduinoDataEntity(
//       uv: 5,
//       light: 100,
//       datetime: DateTime.now(),
//       accel: Int16List.fromList([1, 2, 3]),
//       serverClass: 1,
//       appClass: 2,
//       childId: childId,
//     );
//     dataList.add(data);
//   }
//
//   return dataList;
// }
}
