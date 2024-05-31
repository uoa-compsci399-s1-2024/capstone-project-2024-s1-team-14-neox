import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/participating_child_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/childStudy_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/study_entity.dart';

class StudyRepository {


  Future<List<StudyModel>> getAllParticipatingStudies() async {
    List<StudyEntity> entities = await StudyEntity.queryAllStudy();
    if (entities.isEmpty) {
        return [];
    }
    return entities.map((entity) => StudyModel.fromEntity(entity)).toList();
  }

  Future<List<ParticipatingChildModel>> getAllChildren() async {
    List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    return entities.map((entity) => ParticipatingChildModel.fromEntity(entity)).toList();
  }

Future<List<ParticipatingChildModel>> getChildrenByStudyCode(String studyCode) async {
    List<ChildStudyAssociationsEntity> associations = await ChildStudyAssociationsEntity.getChildrenByStudyCode(studyCode);
    List<ParticipatingChildModel> children = [];
    for (ChildStudyAssociationsEntity child in associations) {
      ChildEntity? entity = await ChildEntity.queryChildById(child.childId);
      children.add(ParticipatingChildModel.fromEntity(entity!));
    }
    return children;
  }

  StudyModel fetchStudyFromServer(String studyCode) {
    return StudyModel(
        studyCode: studyCode,
        name: "Atropine for myopia control",
        description:
            "This project investigates the mechanisms underlying atropine control of eye growth and myopia. Nightly instillation of atropine is the most successful treatment for inhibiting myopia progression at present. However, the site and mode of atropine’s actions are yet to be understood. We are using immunohistochemical, electrophysiological, and imaging techniques on animal models and humans to probe the mechanisms by which atropine exerts its anti-myopia effects.",
        startDate: DateTime(2022, 6, 2),
        endDate: DateTime.now());
  }

  Future<List<StudyModel>> joinNewStudy(
      StudyModel study, List<int> childIds) async {
    await StudyEntity.createStudy(
      StudyEntity(
        name: study.name,
        description: study.description,
        startDate: study.startDate,
        endDate: study.endDate,
        studyCode: study.studyCode,
      ),
    );
    String code = study.studyCode;
    for (int id in childIds) {
      ChildStudyAssociationsEntity.saveSingleChildStudy(id, code);
    }
    return getAllParticipatingStudies();
  }

  Future<List<StudyModel>> addChildToStudy(
      int childId, String studyCode) async {
    ChildStudyAssociationsEntity.saveSingleChildStudy(childId, studyCode);

    return getAllParticipatingStudies();
  }

  Future<List<StudyModel>> deleteChildFromStudy(
      int childId, String studyCode) async {
    ChildStudyAssociationsEntity.deleteChildStudy(childId, studyCode);
    return getAllParticipatingStudies();
  }
  Future<List<StudyModel>> deleteStudy(String studyCode) async {
    StudyEntity.deleteStudy(studyCode);
    return getAllParticipatingStudies();
  }

    


}
