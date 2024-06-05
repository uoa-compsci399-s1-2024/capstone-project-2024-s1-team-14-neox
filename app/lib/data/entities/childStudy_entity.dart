import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:drift/drift.dart';

@UseRowClass(ChildStudyAssociationsEntity)
class ChildStudy extends Table {
  IntColumn get childId => integer()();

  TextColumn get studyCode => text()();

  @override
  Set<Column> get primaryKey => {childId, studyCode};
}

class ChildStudyAssociationsEntity {
  int childId;
  String studyCode;

  ChildStudyAssociationsEntity(
      {required this.childId, required this.studyCode});

  ChildStudyCompanion toCompanion() {
    return ChildStudyCompanion(
      childId: Value(childId),
      studyCode: Value(studyCode),
    );
  }

  static Future<void> saveSingleChildStudy(int childId, String studyCode) async {
    final db = AppDb.instance();
    final existingRecord = await (db.select(db.childStudy)
      ..where((tbl) => tbl.childId.equals(childId) & tbl.studyCode.equals(studyCode))
    ).getSingleOrNull();

    if (existingRecord != null && existingRecord.childId == childId && existingRecord.studyCode == studyCode) {
      // Record already exists, handle accordingly
      print('Record with childId $childId and studyCode $studyCode already exists.');
      return;
    }

    ChildStudyAssociationsEntity childStudyAssociationsEntity = ChildStudyAssociationsEntity(childId: childId, studyCode: studyCode);
    await db.into(db.childStudy).insert(childStudyAssociationsEntity.toCompanion(), mode: InsertMode.insert);
  }


  static Future<void> deleteChildStudy(int childId, String studyCode) async {
    final db = AppDb.instance();
    await (db.delete(db.childStudy)
      ..where((tbl) =>
      tbl.childId.equals(childId) & tbl.studyCode.equals(studyCode)))
        .go();
  }

  static Future<List<ChildStudyAssociationsEntity>> queryAllChildStudies() async {
    final db = AppDb.instance();
    List<ChildStudyAssociationsEntity> studyList =  await db.select(db.childStudy).get();
    return studyList;
  }

  static Future<List<ChildStudyAssociationsEntity>> getChildStudiesByChildId(int childId) async {
    final db = AppDb.instance();
    return await (db.select(db.childStudy)
      ..where((tbl) =>
          tbl.childId.equals(childId)))
        .get();
  }

  static Future<List<ChildStudyAssociationsEntity>> getChildrenByStudyCode(String studyCode) async {
    final db = AppDb.instance();
    return await (db.select(db.childStudy)
      ..where((tbl) =>
          tbl.studyCode.equals(studyCode)))
        .get();
  }


  static Future<ChildStudyAssociationsEntity?> getChildStudyByIdAndCode(int childId, String studyCode) async {
    final db = AppDb.instance();
    return await (db.select(db.childStudy)
      ..where((tbl) =>
      tbl.childId.equals(childId) & tbl.studyCode.equals(studyCode)))
        .getSingleOrNull();
  }


  static Future<void> removeFromStudy(int childId, String studyCode) async {
    final db = AppDb.instance();
    await (db.delete(db.childStudy)
      ..where((tbl) =>
      tbl.childId.equals(childId) & tbl.studyCode.equals(studyCode)))
        .go();
  }

    static Future<void> removeAllChildrenFromStudy(String studyCode) async {
    final db = AppDb.instance();
    await (db.delete(db.childStudy)
      ..where((tbl) => tbl.studyCode.equals(studyCode)))
        .go();
  }

}


