import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/participating_child_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/childStudy_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/study_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_api_service.dart';

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
    return entities
        .map((entity) => ParticipatingChildModel.fromEntity(entity))
        .toList();
  }

  Future<List<ParticipatingChildModel>> getChildrenByStudyCode(
      String studyCode) async {
    List<ChildStudyAssociationsEntity> associations =
        await ChildStudyAssociationsEntity.getChildrenByStudyCode(studyCode);
    List<ParticipatingChildModel> children = [];
    for (ChildStudyAssociationsEntity child in associations) {
      ChildEntity? entity = await ChildEntity.queryChildById(child.childId);
      children.add(ParticipatingChildModel.fromEntity(entity!));
    }
    return children;
  }

  Future<StudyModel?> fetchStudyFromServer(String studyCode) async {
    StudyEntity? study = await ChildApiService.getStudy(studyCode);
    if (study == null) {
      return null;
    }
    return StudyModel.fromEntity(study);
  }

  Future<List<StudyModel>> joinNewStudy(
      StudyModel study, List<int> childIds) async {
    String code = study.studyCode;
    ChildApiService.getStudy(code);
    for (int id in childIds) {
      ChildApiService.addChildToStudy(id, code);
    }
    return getAllParticipatingStudies();
  }

  Future<List<StudyModel>> addChildToStudy(
      int childId, String studyCode) async {
    ChildApiService.addChildToStudy(childId, studyCode);

    return getAllParticipatingStudies();
  }

  Future<List<StudyModel>> deleteChildFromStudy(
      int childId, String studyCode) async {
    ChildApiService.removeChildFromStudy(childId, studyCode);
    // deleteStudy(studyCode);
    return getAllParticipatingStudies();
  }

  Future<List<StudyModel>> deleteStudy(String studyCode) async {
    //post to server
    List<ChildStudyAssociationsEntity> childrenInStudy =
        await ChildStudyAssociationsEntity.getChildrenByStudyCode(studyCode);
    for (ChildStudyAssociationsEntity e in childrenInStudy) {
      ChildApiService.removeChildFromStudy(e.childId, studyCode);
    }

// remove children in study
    await ChildStudyAssociationsEntity.removeAllChildrenFromStudy(studyCode);
    await StudyEntity.deleteStudy(studyCode);
    return getAllParticipatingStudies();
  }
}
