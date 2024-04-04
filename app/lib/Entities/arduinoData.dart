import 'package:capstone_project_2024_s1_team_14_neox/dB/database.dart';
import 'package:drift/drift.dart';

@UseRowClass(ArduinoDataEntity)
class ArduinoDatas extends Table {
  TextColumn get name => text()();
  IntColumn get uv => integer()();
  IntColumn get light => integer()();
  DateTimeColumn get datetime => dateTime()();
}


class ArduinoDataEntity{
  String? name;
  int? uv;
  int? light;
  DateTime datetime;


  ArduinoDataEntity(
      this.name, this.uv, this.light, this.datetime
      );

  ArduinoDatasCompanion toCompanion() {
    return ArduinoDatasCompanion(
      name: Value(name ?? ''),
      uv: Value(uv ?? -1),
      light: Value(light ?? -1),
      datetime: Value(datetime),
    );
  }


  static Future<void> saveSingleArduinoDataEntity(ArduinoDataEntity arduinoDataEntity) async {
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
    List<ArduinoDataEntity> arduinoDataEntityList = await db.select(db.arduinoDatas).get();
    return arduinoDataEntityList;
  }

  static Future<ArduinoDataEntity?> queryArduinoDataByName(String name) async {
    AppDb db = AppDb.instance();
    ArduinoDataEntity? arduinoDataEntity = await (db.select(db.arduinoDatas)
      ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return arduinoDataEntity;
  }

// Example method for querying Arduino data by UV level
  static Future<List<ArduinoDataEntity>> queryListOfArduinoDataByUVLevel(int uvLevel) async {
    AppDb db = AppDb.instance();
    List<ArduinoDataEntity> arduinoDataEntityList = await (db.select(db.arduinoDatas)
      ..where((tbl) => tbl.uv.equals(uvLevel)))
        .get();
    return arduinoDataEntityList;
  }

}