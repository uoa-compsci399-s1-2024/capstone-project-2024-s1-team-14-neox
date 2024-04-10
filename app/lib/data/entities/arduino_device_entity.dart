import 'package:drift/drift.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';

@UseRowClass(ArduinoDeviceEntity)
class ArduinoDevices extends Table {
  TextColumn get deviceRemoteId => text()();

  TextColumn get authorisationCode => text()();
}

class ArduinoDeviceEntity {
  String? deviceRemoteId;
  String? authorisationCode;

  ArduinoDeviceEntity({
    this.deviceRemoteId,
    this.authorisationCode,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'deviceRemoteId': deviceRemoteId,
      'authorisationCode': authorisationCode,
    };
  }

  // JSON deserialization
  factory ArduinoDeviceEntity.fromJson(Map<String, dynamic> json) {
    return ArduinoDeviceEntity(
      deviceRemoteId: json['deviceRemoteId'],
      authorisationCode: json['authorisationCode'],
    );
  }

  ArduinoDevicesCompanion toCompanion() {
    return ArduinoDevicesCompanion(
      deviceRemoteId: Value(deviceRemoteId ?? ''),
      authorisationCode: Value(authorisationCode ?? ''),
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
    List<ArduinoDeviceEntity> arduinoDeviceEntityList =
        await db.select(db.arduinoDevices).get();
    return arduinoDeviceEntityList;
  }

  static Future<ArduinoDeviceEntity?> queryArduinoDeviceById(
      String deviceId) async {
    AppDb db = AppDb.instance();
    ArduinoDeviceEntity? arduinoDeviceEntity =
        await (db.select(db.arduinoDevices)
              ..where((tbl) => tbl.deviceRemoteId.equals(deviceId)))
            .getSingleOrNull();
    return arduinoDeviceEntity;
  }
}
