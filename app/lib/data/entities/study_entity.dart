import 'package:drift/drift.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';

@UseRowClass(StudyEntity)
class Study extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get studyCode => text()();

  TextColumn get name => text()();

  TextColumn get description => text()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();


}

class StudyEntity {
  int? id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String studyCode;

  StudyEntity(
      {this.id,
      required this.name,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.studyCode});

  StudyCompanion toCompanion() {
    return StudyCompanion(
        name: Value(name),
        description: Value(description),
        startDate: Value(startDate),
        endDate: Value(endDate),
        studyCode: Value(studyCode));
  }

// QUERIES

///////////////////////////////////////////////////////////////
//   // CREATE ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

  static Future<void> createStudy(StudyEntity study) async {
    AppDb db = AppDb.instance();

    // Check if a study with the same unique attribute (e.g., name) exists
    final existingStudy = await (db.select(db.study)
      ..where((tbl) => tbl.name.equals(study.name)))
        .getSingleOrNull();

    // Insert only if the study does not already exist
    if (existingStudy == null) {
      await db.into(db.study).insert(study.toCompanion(), mode: InsertMode.insert);
    }
  }


  ////////////////////////////////////////////////////////////////////////////
  // READ ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  static Future<StudyEntity?> queryStudyByCode(String studyCode) async {
    AppDb db = AppDb.instance();
    StudyEntity? child = await (db.select(db.study)
          ..where((tbl) => tbl.studyCode.equals(studyCode)))
        .getSingleOrNull();

    return child;
  }

  static Future<List<StudyEntity>> queryAllStudy() async {
    AppDb db = AppDb.instance();
    List<StudyEntity> studyList = await db.select(db.study).get();
    return studyList;
  }

////////////////////////////////////////////////////////////////////////////
// DELETE //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

  static Future<void> deleteStudy(String studyCode) async {
    AppDb db = AppDb.instance();
    await (db.delete(db.study)..where((tbl) => tbl.studyCode.equals(studyCode)))
        .go();
  }

  static Future<void> clearStudyTable() async {
    final db = AppDb.instance();
    await db.delete(db.study).go();
  }

  factory StudyEntity.fromJson(Map<String, dynamic> json, String studyCode) {
     StudyEntity study = StudyEntity(name: json["name"],
        description: json["description"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        studyCode: studyCode);
    return study;
  }







}
