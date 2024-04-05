import 'dart:io';

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_device_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Children, ArduinoDevices, ArduinoDatas])
class AppDb extends _$AppDb {
  static final AppDb _instance = AppDb();

  static AppDb instance() => _instance;

  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

//Basic CRUD queries
// insert new data Entities
}