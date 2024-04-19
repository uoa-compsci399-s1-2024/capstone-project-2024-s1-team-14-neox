import 'package:drift/drift.dart';
import '../../server/child_data.dart';
import 'arduino_device_entity.dart';
import 'arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_api_service.dart';

@UseRowClass(ChildEntity)
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().references(ArduinoDatas, #name)();

  DateTimeColumn get birthDate => dateTime()();

  TextColumn get deviceRemoteId =>
      text().references(ArduinoDevices, #deviceRemoteId)();

  // Terimnal [WARNING]  Tables can't override primaryKey and use autoIncrement()
  // @override
  // Set<Column> get primaryKey => {id};
}

class ChildEntity {
  int? id;
  String name;
  DateTime birthDate;
  String? deviceRemoteId;
  ArduinoDeviceEntity? arduinoDeviceEntity;

  //TODO: deviceRemoteId is duplicated in child entity and arduino device entity

  ChildEntity(
      {required this.name,
      required this.birthDate,
      this.deviceRemoteId,
      this.id});

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'deviceRemoteId': deviceRemoteId,
    };
  }

  // JSON deserialization
// JSON deserialization
  factory ChildEntity.fromJson(Map<String, dynamic> json) {
    return ChildEntity(
      name: json['name'],
      birthDate: json['birthDate'],
      deviceRemoteId: json['deviceRemoteId'],
    );
  }

  ChildrenCompanion toCompanion() {
    return ChildrenCompanion(
      name: Value(name),
      birthDate: Value(birthDate),
      deviceRemoteId: Value(deviceRemoteId ?? ''),
    );
  }

  // CREATE
  static Future<void> saveSingleChildEntity(ChildEntity childEntity) async {
    AppDb db = AppDb.instance();
    await db
        .into(db.children)
        .insert(childEntity.toCompanion(), mode: InsertMode.insert);
    print(childEntity.name);
  }

  static Future<void> saveListOfChildren(
      List<ChildEntity> childEntityList) async {
    await Future.forEach(childEntityList, (childEntity) async {
      await saveSingleChildEntity(childEntity);
    });
  }

  static Future<void> saveSingleChildEntityFromParameters(
      String name, DateTime birthDate) async {
    ChildEntity childEntity = ChildEntity(name: name, birthDate: birthDate);
    AppDb db = AppDb.instance();
    await db
        .into(db.children)
        .insert(childEntity.toCompanion(), mode: InsertMode.insert);
  }

  // READ
  static Future<ChildEntity?> queryChildById(int id) async {
    AppDb db = AppDb.instance();
    ChildEntity? child = await (db.select(db.children)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return child;
  }

  static Future<List<ChildEntity>> queryAllChildren() async {
    AppDb db = AppDb.instance();
    List<ChildEntity> childEntityList = await db.select(db.children).get();
    
    // Remove arduino device entity
    // await Future.forEach(childEntityList, (childEntity) async {
    //   childEntity.arduinoDeviceEntity =
    //       await queryArduinoDeviceBydeviceRemoteId(
    //           childEntity.deviceRemoteId ?? '');
    // });

    // ChildData child = await ChildApiService.fetchChildDataById(22);
    // print('Timestamp: ${child.tstamp}');
    // print('Child ID: ${child.childId}');
    // print('UV Index: ${child.uvIndex}');
    // print('Lux: ${child.lux}');
    // print('');
    return childEntityList;
  }

  static Future<ChildEntity?> queryChildByName(String name) async {
    AppDb db = AppDb.instance();
    ChildEntity? childEntity = await (db.select(db.children)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    if (childEntity != null) {
      childEntity.arduinoDeviceEntity =
          await queryArduinoDeviceBydeviceRemoteId(
              childEntity.deviceRemoteId ?? '');
    }
    return childEntity;
  }

  static Future<ArduinoDeviceEntity?> queryArduinoDeviceBydeviceRemoteId(
      String deviceRemoteId) async {
    return await ArduinoDeviceEntity.queryArduinoDeviceById(deviceRemoteId);
  }

  static Future<List<ArduinoDataEntity>> getAllDataForChild(int childId) async {
    List<ArduinoDataEntity> data =
        await ArduinoDataEntity.queryArduinoDataById(childId);
    return data;
  }

  // UPDATE
  static Future<void> updateRemoteDeviceId(
      int? childId, String remoteDeviceId) async {
    if (childId == null) {
      throw Exception("Child ID cannot be null");
    } else {
      AppDb db = AppDb.instance();
      await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
          .write(ChildrenCompanion(deviceRemoteId: Value(remoteDeviceId)));
    }
  }

  // DELETE
  static Future<void> deleteDeviceForChild(int? childId) async {
    if (childId == null) {
      throw Exception("Child ID cannot be null");
    } else {
      AppDb db = AppDb.instance();
      await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
          .write(const ChildrenCompanion(deviceRemoteId: Value("")));
    }
  }

  static Future<void> deleteChild(int childId) async {
    AppDb db = AppDb.instance();

    // Delete the child entity from the database based on its ID
    // print("count of${db.children.id.count(filter: childId > 0)}");
    await db.delete(db.children)
      ..where((tbl) => tbl.id.equals(childId));
    print("count of${db.children.id.count()}");
  }

  @override
  String toString() {
    return "$id, $name, $birthDate, $deviceRemoteId \n";
  }
}
