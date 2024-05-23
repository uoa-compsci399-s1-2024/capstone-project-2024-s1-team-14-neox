import 'dart:io';

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/childStudy_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/study_entity.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase(file, logStatements: false); // Initialize NativeDatabase here
  });
}

@DriftDatabase(tables: [ Children, ArduinoDatas, Study, ChildStudy])
class AppDb extends _$AppDb {
  static final AppDb _instance = AppDb();

  static AppDb instance() => _instance;

  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Create the database schema
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Execute custom SQL statements before opening the database
      await customStatement('PRAGMA foreign_keys = ON;', []);
    },
  );

  Future<void> customStatement(String sql, [List<dynamic>? args]) async {
    await executor.runSelect(sql, args ?? []);
  }


  Future<void> exportInto(File file) async {
    // Make sure the directory of the target file exists
    await file.parent.create(recursive: true);

    // Override an existing backup, sqlite expects the target file to be empty
    if (file.existsSync()) {
      file.deleteSync();
    }

    await customStatement('VACUUM INTO ?', [file.path]);
  }
  
  Future<void> deleteEverything() {
    return transaction(() async {
      await customStatement('PRAGMA foreign_keys = OFF');
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  } 
}