//TODO study entity

import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/participating_child_model.dart';

class StudyModel {
  final String studyId;
  final String name;
  final String description;
  List<ParticipatingChildModel>? participants;

  StudyModel({
    required this.studyId,
    required this.name,
    required this.description,
  });


  // TODO create from entity
  factory StudyModel.fromEntity(var entity) => StudyModel(
    studyId: entity.studyId,
    name: entity.name,
    description: entity.description,

  );
}
