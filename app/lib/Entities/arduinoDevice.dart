import 'package:drift/drift.dart';
import 'package:capstone_project_2024_s1_team_14_neox/dB/database.dart';

@UseRowClass(ArduinoDeviceEntity)
class ArduinoDevices extends Table {
  TextColumn get uuid => text()();
  TextColumn get gatt => text()();
}

class ArduinoDeviceEntity {
  String? uuid;
  String? gatt;

  ArduinoDeviceEntity({
    this.uuid,
    this.gatt,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'gatt': gatt,
    };
  }

  // JSON deserialization
  factory ArduinoDeviceEntity.fromJson(Map<String, dynamic> json) {
    return ArduinoDeviceEntity(
      uuid: json['uuid'],
      gatt: json['gatt'],
    );
  }

  ArduinoDevicesCompanion toCompanion() {
    return ArduinoDevicesCompanion(
      uuid: Value(uuid ?? ''),
      gatt: Value(gatt ?? ''),
    );
  }

  static Future<void> saveSingleArduinoDeviceEntity(
      ArduinoDeviceEntity arduinoDeviceEntity) async {
    AppDb db = AppDb.instance();
    await db
        .into(db.arduinoDevices)
        .insertOnConflictUpdate(arduinoDeviceEntity.toCompanion());
  }


  static Future<List<ArduinoDeviceEntity>> queryAllArduinoDevices() async {
    AppDb db = AppDb.instance();
    List<ArduinoDeviceEntity> arduinoDeviceEntityList = await db.select(db.arduinoDevices).get();
    return arduinoDeviceEntityList;
  }

  static Future<ArduinoDeviceEntity?> queryArduinoDeviceById(String deviceId) async {
    AppDb db = AppDb.instance();
    ArduinoDeviceEntity? arduinoDeviceEntity = await (db.select(db.arduinoDevices)
      ..where((tbl) => tbl.uuid.equals(deviceId)))
        .getSingleOrNull();
    return arduinoDeviceEntity;
  }


}