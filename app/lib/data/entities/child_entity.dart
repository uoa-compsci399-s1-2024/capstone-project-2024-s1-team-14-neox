import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/childStudy_entity.dart';
import 'package:drift/drift.dart';
import 'arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_api_service.dart';

@UseRowClass(ChildEntity)
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get serverId => text()();

  TextColumn get name => text()();

  DateTimeColumn get birthDate => dateTime()();

  TextColumn get deviceRemoteId => text()();

  TextColumn get authorisationCode => text()();

  TextColumn get gender => text()();
}

class ChildEntity {
  int? id;
  String name;
  DateTime birthDate;
  String? deviceRemoteId;
  String? authorisationCode;
  String? serverId;
  String gender;

  //TODO: deviceRemoteId is duplicated in child entity and arduino device entity

  ChildEntity({
    required this.name,
    required this.gender,
    required this.birthDate,
    this.deviceRemoteId,
    this.authorisationCode,
    this.serverId,
    this.id,
  });

  ChildrenCompanion toCompanion() {
    return ChildrenCompanion(
      name: Value(name),
      serverId: Value(serverId ?? ''),
      birthDate: Value(birthDate),
      deviceRemoteId: Value(deviceRemoteId ?? ''),
      authorisationCode: Value(authorisationCode ?? ''),
      gender: Value(gender),
    );
  }

  ///////////////////////////////////////////////////////////////
  //   // CREATE ///////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<void> saveSingleChildEntity(ChildEntity childEntity) async {
    AppDb db = AppDb.instance();
    await db
        .into(db.children)
        .insert(childEntity.toCompanion(), mode: InsertMode.insert);
    // print(childEntity.name);
  }

  static Future<void> saveListOfChildren(
      List<ChildEntity> childEntityList) async {
    await Future.forEach(childEntityList, (childEntity) async {
      await saveSingleChildEntity(childEntity);
    });
  }

  static Future<int> saveSingleChildEntityFromParameters(
      String name, DateTime birthDate, String gender) async {
    // String serverId = await ChildApiService.registerChild();

    ChildEntity childEntity = ChildEntity(
      name: name,
      gender: gender,
      birthDate: birthDate,
      serverId: "",
    );

    AppDb db = AppDb.instance();
    int id = await db
        .into(db.children)
        .insert(childEntity.toCompanion(), mode: InsertMode.insert);
    return id;
  }

  ////////////////////////////////////////////////////////////////////////////
  // READ ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
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

  static Future<ChildEntity?> queryChildByServerId(String serverId) async {
    AppDb db = AppDb.instance();
    ChildEntity? childEntity = await (db.select(db.children)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
    return childEntity;
  }

  static Future<ChildEntity?> queryChildByDeviceRemoteId(
      String deviceRemoteId) async {
    AppDb db = AppDb.instance();
    return await (db.select(db.children)
          ..where((tbl) => tbl.deviceRemoteId.equals(deviceRemoteId)))
        .getSingleOrNull();
  }

  static Future<List<ArduinoDataEntity>> getAllDataForChild(int childId) async {
    List<ArduinoDataEntity> data =
        await ArduinoDataEntity.queryArduinoDataById(childId);
    return data;
  }

  static Future<List<ChildEntity>> queryChildNoServerId() async {
    AppDb db = AppDb.instance();
    return await (db.select(db.children)
          ..where((tbl) => tbl.serverId.equals("")))
        .get();
  }

  ////////////////////////////////////////////////////////////////////////////
  // UPDATE //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  static Future<void> updateRemoteDeviceId(
      int childId, String deviceRemoteId) async {
    AppDb db = AppDb.instance();
    await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
        .write(ChildrenCompanion(deviceRemoteId: Value(deviceRemoteId)));
  }

  static Future<void> updateAuthorisationCode(int childId, String code) async {
    AppDb db = AppDb.instance();
    await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
        .write(ChildrenCompanion(authorisationCode: Value(code)));
  }

  static Future<void> updateChildDetails(
    int childId,
    String name,
    DateTime birthDate,
    String gender,
    String authorisationCode,
  ) async {
    AppDb db = AppDb.instance();
    await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
        .write(ChildrenCompanion(
      name: Value(name),
      birthDate: Value(birthDate),
      gender: Value(gender),
      authorisationCode: Value(authorisationCode),
    ));
  }

  static Future<void> updateServerId(int childId, String serverId) async {
    AppDb db = AppDb.instance();
    await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
        .write(ChildrenCompanion(serverId: Value(serverId)));
  }

  ////////////////////////////////////////////////////////////////////////////
  // DELETE //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  static Future<void> deleteDeviceForChild(int childId) async {
    AppDb db = AppDb.instance();
    await (db.update(db.children)..where((tbl) => tbl.id.equals(childId)))
        .write(const ChildrenCompanion(deviceRemoteId: Value("")));
  }

  static Future<void> deleteChild(int childId) async {
    AppDb db = AppDb.instance();
    // Delete the child entity from the database based on its ID
    // print("count of${db.children.id.count(filter: childId > 0)}");

    var studies =
        await ChildStudyAssociationsEntity.getChildStudiesByChildId(childId);
    for (final study in studies) {
      ChildApiService.removeChildFromStudy(childId, study.studyCode);
    }

    await (db.delete(db.children)..where((tbl) => tbl.id.equals(childId))).go();
  }

  ////////////////////////////////////////////////////////////////////////////
  // CAN BE DELETED LATER////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  @override
  String toString() {
    return "$id, $name, $birthDate, $deviceRemoteId \n";
  }

  //////////////////////////////////
  ///           CLOUD            ///
  //////////////////////////////////

  static Future<void> uploadAllChildData() async {
    List<ChildEntity> noServerIdChildren =
        await ChildEntity.queryChildNoServerId();
    // Register child in server if no serverId is not found
    for (final noServerIdChild in noServerIdChildren) {
      String generatedServerId = await ChildApiService.registerChild();
      await ChildEntity.updateServerId(noServerIdChild.id!, generatedServerId);
      await ChildApiService.setChildInfo(noServerIdChild.id);
    }

    List<ChildEntity> children = await ChildEntity.queryAllChildren();

    for (final child in children) {
      // update child details in case it changes
      await ChildApiService.setChildInfo(child.id);

      if (child.serverId == "") {}
      int? id = child.id;
      await ChildApiService.postData(id!);
    }
  }

  static Future<void> downloadAllChildData() async {
// Create profiles for children not in local db
    await ChildEntity.retrieveChildrenInServer();

    List<ChildEntity> childrenInDb = await ChildEntity.queryAllChildren();
    for (ChildEntity child in childrenInDb) {
      await ChildApiService.fetchChildrenData(child.id!);
    }
  }

  static Future<void> retrieveChildrenInServer() async {
    List<String> serverIdList = await ChildApiService.getChildren();
    for (final String id in serverIdList) {
      ChildEntity? child = await ChildApiService.getChildInfo(id);
      if (child != null) {
        // Depends on the server id of the child
        if (await ChildEntity.queryChildByServerId(id) == null) {
          ChildEntity.saveSingleChildEntity(child);
        }
      }
    }
  }
}
