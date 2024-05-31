//TODO study entity

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/study_entity.dart';

class StudyModel {
  final String studyCode;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  StudyModel({
    required this.studyCode,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory StudyModel.fromEntity(StudyEntity entity) => StudyModel(
        studyCode: entity.studyCode,
        name: entity.name,
        description: entity.description,
        startDate: entity.startDate,
        endDate: entity.endDate,
      );

    @override
    String toString() => "$studyCode $name";
}
