import 'package:drift/drift.dart';
import 'arduino_device_entity.dart';
import 'arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';

@UseRowClass(ChildEntity)
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().references(ArduinoDatas, #name)();
  DateTimeColumn get birthDate => dateTime()(); 
  TextColumn get deviceRemoteId => text().references(ArduinoDevices, #deviceRemoteId)();

  @override
  Set<Column> get primaryKey => {id};
}

class ChildEntity {
  int? id;
  String name;
  DateTime birthDate;
  String? deviceRemoteId;
  ArduinoDeviceEntity? arduinoDeviceEntity;

  ChildEntity({required this.name, required this.birthDate, this.deviceRemoteId});

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
  static Future<void> saveSingleChildEntity(
      ChildEntity childEntity) async {
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
    print(childEntity.name);
  }

  // READ
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
      await queryArduinoDeviceBydeviceRemoteId(childEntity.deviceRemoteId ?? '');
    }
    return childEntity;
  }

  static Future<ArduinoDeviceEntity?> queryArduinoDeviceBydeviceRemoteId(String deviceRemoteId) async {
    // Assuming ArduinoDeviceEntity has a method similar to queryDeviceByChildModelId
    return await ArduinoDeviceEntity.queryArduinoDeviceById(deviceRemoteId);
  }
    // UPDATE


    // DELETE

  // TODO update remoteDeviceID for a child with ID number;
}
