import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';

import 'child_entity.dart';

@UseRowClass(ArduinoDataEntity)
class ArduinoDatas extends Table {
  TextColumn get name => text()();

  IntColumn get id => integer().references(Children, #id)();

  IntColumn get uv => integer()();

  IntColumn get light => integer()();

  DateTimeColumn get datetime => dateTime()();

  IntColumn get accelX => integer()();

  IntColumn get accelY => integer()();

  IntColumn get accelZ => integer()();
}

class ArduinoDataEntity {
  String? name;
  int? uv;
  int? light;
  DateTime datetime;
  Int16List? accel;
  int? id;

  ArduinoDataEntity(
      {this.id, this.name, this.uv, this.light, required this.datetime, this.accel, });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uv': uv,
      'light': light,
      'datetime': datetime.toIso8601String(),
      'accel': accel?.toList(),
    };
  }

  factory ArduinoDataEntity.fromJson(Map<String, dynamic> json) {
    return ArduinoDataEntity(
      name: json['name'],
      uv: json['uv'],
      light: json['light'],
      datetime: DateTime.parse(json['datetime']),
      accel: (json['accel'] != null)
          ? Int16List.fromList(List<int>.from(json['accel']))
          : null,

    );
  }

  ArduinoDatasCompanion toCompanion() {
    return ArduinoDatasCompanion(
      name: Value(name ?? ''),
      uv: Value(uv ?? -1),
      light: Value(light ?? -1),
      datetime: Value(datetime),
      accelX: Value(accel?[0] ?? 0),
      accelY: Value(accel?[1] ?? 0),
      accelZ: Value(accel?[2] ?? 0),
      id: Value(id ?? 0),
    );
  }

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

  static Future<List<ArduinoDataEntity>> queryAllArduinoData() async {
    AppDb db = AppDb.instance();
    List<ArduinoDataEntity> arduinoDataEntityList =
        await db.select(db.arduinoDatas).get();
    return arduinoDataEntityList;
  }

  static Future<List<ArduinoDataEntity>> queryArduinoDataByName(String name) async {
    final db = AppDb.instance();
    final query = db.select(db.arduinoDatas)..where((tbl) => tbl.name.equals(name));
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
}

