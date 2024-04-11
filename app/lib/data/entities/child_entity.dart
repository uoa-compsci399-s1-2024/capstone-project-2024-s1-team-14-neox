import 'package:drift/drift.dart';
import 'arduino_device_entity.dart';
import 'arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';

@UseRowClass(ChildEntity)
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().references(ArduinoDatas, #name)();

  DateTimeColumn get birthDate => dateTime()();

  TextColumn get deviceRemoteId =>
      text().references(ArduinoDevices, #deviceRemoteId)();

  @override
  Set<Column> get primaryKey => {id};
}

class ChildEntity {
  int? id;
  String name;
  DateTime birthDate;
  String? deviceRemoteId;
  ArduinoDeviceEntity? arduinoDeviceEntity;

  ChildEntity(
      {required this.name, required this.birthDate, this.deviceRemoteId, this.id});

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
      //TODO Change default value if birthDate is null

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
    return await (db.select(db.children)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  static Future<List<ChildEntity>> queryAllChildren() async {
    AppDb db = AppDb.instance();
    List<ChildEntity> childEntityList = await db.select(db.children).get();
    // await Future.forEach(childEntityList, (childEntity) async {
    //   childEntity.arduinoDeviceEntity =
    //   await queryArduinoDeviceBydeviceRemoteId(childEntity.deviceRemoteId ?? '');
    // });
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
    AppDb db = AppDb.instance();
    ChildEntity? child = await ChildEntity.queryChildById(childId);
    String? name = child?.name;
    List<ArduinoDataEntity> data =
        await ArduinoDataEntity.queryArduinoDataByName(name!);
    return data;
  }

  // UPDATE
  static Future<void> updateRemoteDeviceId(
      int? id, String remoteDeviceId) async {
  if (id == null) throw Exception("Child ID cannot be null");
    ChildEntity? child = await queryChildById(id);
    AppDb db = AppDb.instance();


    if (child != null) {
      await db.update(db.children).replace(ChildrenCompanion(
          id: Value(id), deviceRemoteId: Value(remoteDeviceId)));
    } else {
      throw Exception('Child with ID $id not found');
    }
  }

  // DELETE
  static Future<void> deleteDeviceForChild(int? childId) async {
      if (childId == null) throw Exception("Child ID cannot be null");
    
    AppDb db = AppDb.instance();

    ChildEntity? child = await queryChildById(childId);
    if (child != null) {
      child.deviceRemoteId = null; // or ''

      await db.update(db.children).replace(child.toCompanion());
    }
  }

  static Future<void> deleteChild(int childId) async {
    AppDb db = AppDb.instance();

    // Delete the child entity from the database based on its ID
    await db.delete(db.children)
      ..where((tbl) => tbl.id.equals(childId));
  }
}
