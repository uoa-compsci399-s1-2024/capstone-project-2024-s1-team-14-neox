import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class StudyInfoTile extends StatelessWidget {
  final StudyModel study;
  final bool flexible;

  const StudyInfoTile(this.study, {super.key, this.flexible = false});

  @override
  Widget build(BuildContext context) {
    Widget description = Text(
      study.description,
      overflow: TextOverflow.fade,
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
    return Column(
      children: [
        Text(
          study.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Running period\n${DateFormat("d MMMM yyyy").format(study.startDate)} ~ ${DateFormat("d MMMM yyyy").format(study.endDate)}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        flexible ? Flexible(child: description) : description,
      ],
    );
  }
}
