import 'package:drift/drift.dart';
import 'arduinoDevice.dart';
import 'arduinoData.dart';
import 'package:capstone_project_2024_s1_team_14_neox/dB/database.dart';

@UseRowClass(ChildModelEntity)
class ChildModels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().references(ArduinoDatas, #name)();
  IntColumn get age => integer()();
  TextColumn get uuid => text().references(ArduinoDevices, #uuid)();

  @override
  Set<Column> get primaryKey => {id};
}

class ChildModelEntity {
  int? id;
  String? name;
  int? age;
  String? uuid;
  ArduinoDeviceEntity? arduinoDeviceEntity;

  ChildModelEntity({this.name, this.age, this.uuid});

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'uuid': uuid,
    };
  }

  // JSON deserialization
// JSON deserialization
  factory ChildModelEntity.fromJson(Map<String, dynamic> json) {
    return ChildModelEntity(
      name: json['name'],
      age: json['age'],
      uuid: json['uuid'],
    );
  }


  ChildModelsCompanion toCompanion() {
    return ChildModelsCompanion(
      name: Value(name ?? ''),
      age: Value(age ?? -1),
      uuid: Value(uuid ?? ''),
    );
  }


  static Future<void> saveSingleChildModelEntity(
      ChildModelEntity childModelEntity) async {
    AppDb db = AppDb.instance();
    await db
        .into(db.childModels)
        .insert(childModelEntity.toCompanion(), mode: InsertMode.insert);
    print(childModelEntity.name);
  }

  static Future<void> saveListOfChildModels(
      List<ChildModelEntity> childModelEntityList) async {
    await Future.forEach(childModelEntityList, (childModelEntity) async {
      await saveSingleChildModelEntity(childModelEntity);
    });
  }

  static Future<List<ChildModelEntity>> queryAllChildModels() async {
    AppDb db = AppDb.instance();
    List<ChildModelEntity> childModelEntityList = await db.select(db.childModels).get();
    await Future.forEach(childModelEntityList, (childModelEntity) async {
      childModelEntity.arduinoDeviceEntity =
      await queryArduinoDeviceByUuid(childModelEntity.uuid ?? '');
    });
    return childModelEntityList;
  }

  static Future<ChildModelEntity?> queryChildModelByName(String name) async {
    AppDb db = AppDb.instance();
    ChildModelEntity? childModelEntity = await (db.select(db.childModels)
      ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    if (childModelEntity != null) {
      childModelEntity.arduinoDeviceEntity =
      await queryArduinoDeviceByUuid(childModelEntity.uuid ?? '');
    }
    return childModelEntity;
  }

  static Future<ArduinoDeviceEntity?> queryArduinoDeviceByUuid(String uuid) async {
    // Assuming ArduinoDeviceEntity has a method similar to queryDeviceByChildModelId
    return await ArduinoDeviceEntity.queryArduinoDeviceById(uuid);
  }

}
