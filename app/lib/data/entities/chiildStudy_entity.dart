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
}
