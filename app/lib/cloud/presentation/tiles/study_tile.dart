import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/participants_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/participating_child_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StudyTile extends StatelessWidget {
  final StudyModel study;
  final VoidCallback onStudyDelete;

  // TODO pass function to add and delete children, like how you will do for scan in bluetooth bloc
  const StudyTile(
      {super.key, required this.study, required this.onStudyDelete});

  Widget buildParticipating(
      BuildContext context, List<ParticipatingChildModel> participating) {
    return Column(
      children: [
        Text("Current participants"),
        ...participating.map((child) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  child.childName,
                  style: TextStyle(fontSize: 24),
                ),
                IconButton(
                    iconSize: 32,
                    onPressed: () => context
                        .read<ParticipantsCubit>()
                        .deleteChildFromStudy(child.childId, study.studyCode),
                    icon: const Icon(Icons.delete_outline))
              ],
            ))
      ],
    );
  }

  Widget buildNotParticipating(
      BuildContext context, List<ParticipatingChildModel> notParticipating) {
    return Column(
      children: [
        Text("Add a participant"),
        ...notParticipating.map((child) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  child.childName,
                  style: TextStyle(fontSize: 24),
                ),
                IconButton(
                    iconSize: 32,
                    onPressed: () => context
                        .read<ParticipantsCubit>()
                        .addChildToStudy(child.childId, study.studyCode),
                    icon: const Icon(Icons.add))
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 800,
            child: Column(
              children: [
                Text(
                  study.name,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Text(
                    study.description,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                Text(
                  DateFormat("dd MMMM yyyy").format(study.startDate) +
                      "~" +
                      DateFormat("dd MMMM yyyy").format(study.endDate),
                  style: const TextStyle(fontSize: 16.0),
                ),
                BlocProvider(
                  create: (_) =>
                      ParticipantsCubit(context.read<StudyRepository>())
                        ..getParticipatingStatus(study.studyCode),
                  child: BlocBuilder<ParticipantsCubit, ParticipantsState>(
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return CircularProgressIndicator();
                      }
                      return Column(
                        children: [
                          if (state.participating.isNotEmpty)
                            buildParticipating(context, state.participating),
                          if (state.notParticipating.isNotEmpty)
                            buildNotParticipating(
                                context, state.notParticipating),
                        ],
                      );
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      onStudyDelete();
                      Navigator.pop(context);
                    },
                    child: Text("Withdraw"))
              ],
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          width: 300,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                study.name,
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  study.description,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              Text(
                DateFormat("dd MMMM yyyy").format(study.startDate) +
                    "~" +
                    DateFormat("dd MMMM yyyy").format(study.endDate),
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
