
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';

class ParticipatingChildModel {
  final int childId;
  final String childName;
  // TODO Participating from date?

  ParticipatingChildModel({
    required this.childId,
    required this.childName,
  });

  factory ParticipatingChildModel.fromEntity(ChildEntity entity) => ParticipatingChildModel(
        childId: entity.id!, // NONNULL CHILDID
        childName: entity.name,
      );

  @override
  String toString() => "$childId, $childName\n";

}
