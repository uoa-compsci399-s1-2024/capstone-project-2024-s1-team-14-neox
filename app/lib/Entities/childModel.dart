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

  ChildModelEntity({this.id, this.name, this.age, this.uuid});

  ChildModelsCompanion toCompanion() {
    return ChildModelsCompanion(
      id: Value(id ?? -1),
      name: Value(name ?? ''),
      age: Value(age ?? -1),
      uuid: Value(uuid ?? ''),
    );
  }

  static Future<void> saveSingleChildModelEntity(
      ChildModelEntity childModelEntity) async {
    AppDb db = AppDb();
    await db
        .into(db.childModels)
        .insertOnConflictUpdate(childModelEntity.toCompanion());
  }

  static Future<void> saveListOfChildModels(
      List<ChildModelEntity> childModelEntityList) async {
    await Future.forEach(childModelEntityList, (childModelEntity) async {
      await saveSingleChildModelEntity(childModelEntity);
    });
  }

  static Future<List<ChildModelEntity>> queryAllChildModels() async {
    AppDb db = AppDb();
    List<ChildModelEntity> childModelEntityList = await db.select(db.childModels).get();
    await Future.forEach(childModelEntityList, (childModelEntity) async {
      childModelEntity.arduinoDeviceEntity =
      await queryArduinoDeviceByUuid(childModelEntity.uuid ?? '');
    });
    return childModelEntityList;
  }

  static Future<ChildModelEntity?> queryChildModelByName(String name) async {
    AppDb db = AppDb();
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
