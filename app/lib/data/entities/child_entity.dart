import 'package:drift/drift.dart';
import '../../server/child_data.dart';
import 'arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_api_service.dart';

@UseRowClass(ChildEntity)
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get serverId => integer()();

  TextColumn get name => text()();

  DateTimeColumn get birthDate => dateTime()();

  TextColumn get deviceRemoteId => text()();

  TextColumn get authorisationCode => text()();
}

class ChildEntity {
  int? id;
  String name;
  DateTime birthDate;
  String? deviceRemoteId;
  String? authorisationCode;
  int? serverId;

  //TODO: deviceRemoteId is duplicated in child entity and arduino device entity

  ChildEntity(
      {required this.name,
      required this.birthDate,
      this.deviceRemoteId,
      this.authorisationCode,
      this.serverId,
      this.id});

  ChildrenCompanion toCompanion() {
    return ChildrenCompanion(
      name: Value(name),
      serverId: Value(serverId ?? 0),
      birthDate: Value(birthDate),
      deviceRemoteId: Value(deviceRemoteId ?? ''),
      authorisationCode: Value(authorisationCode ?? ''),
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
    ChildEntity childEntity = ChildEntity(
      name: name,
      birthDate: birthDate,
    );
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

    return childEntityList;
  }

  static Future<ChildEntity?> queryChildByName(String name) async {
    AppDb db = AppDb.instance();
    ChildEntity? childEntity = await (db.select(db.children)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
    return childEntity;
  }

  static Future<ChildEntity?> queryChildByDeviceRemoteId(String deviceRemoteId) async {
    AppDb db = AppDb.instance();
    return await (db.select(db.children)..where((tbl) => tbl.deviceRemoteId.equals(deviceRemoteId))).getSingleOrNull();
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
    await (db.delete(db.children)..where((tbl) => tbl.id.equals(childId))).go();
    print("count of ${db.children.id.count()}");
  }

  @override
  String toString() {
    return "$id, $name, $birthDate, $deviceRemoteId \n";
  }
}
