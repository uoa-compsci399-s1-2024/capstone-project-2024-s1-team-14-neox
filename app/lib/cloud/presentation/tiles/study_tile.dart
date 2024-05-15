import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/participants_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StudyTile extends StatelessWidget {
  final StudyModel study;
  final VoidCallback onStudyDelete;

  // TODO pass function to add and delete children, like how you will do for scan in bluetooth bloc
  const StudyTile(
      {super.key, required this.study, required this.onStudyDelete});

  Widget buildParticipationList(BuildContext context, ParticipantsState state) {
    return Column(
      children: [
        const Text(
          "Participants",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ...state.allChildren.map((child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              child.childName,
              style: const TextStyle(fontSize: 18),
            ),
            state.participating.any((other) => other.childId == child.childId)
              ? IconButton(
                iconSize: 32,
                onPressed: () => context
                  .read<ParticipantsCubit>()
                  .deleteChildFromStudy(child.childId, study.studyCode),
                icon: const Icon(Icons.remove))
              : IconButton(
                iconSize: 32,
                onPressed: () => context
                  .read<ParticipantsCubit>()
                  .addChildToStudy(child.childId, study.studyCode),
                icon: const Icon(Icons.add)),
          ],
        ))
      ],
    );
  }

  Widget _buildStudyContent(BuildContext context, { required bool flexible }) {
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Running period ${DateFormat("d MMMM yyyy").format(study.startDate)} ~ ${DateFormat("d MMMM yyyy").format(study.endDate)}",
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        flexible ? Flexible(child: description) : description,
      ],
    );
  }

  void _showBottomSheetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  _buildStudyContent(context, flexible: false),
              
                  const Divider(height: 50),
                  
                  BlocProvider(
                    create: (_) => ParticipantsCubit(context.read<StudyRepository>())..getParticipatingStatus(study.studyCode),
                    child: BlocBuilder<ParticipantsCubit, ParticipantsState>(
                      builder: (context, state) {
                        if (state.status.isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return buildParticipationList(context, state);
                      },
                    ),
                  ),
                  
                  const Divider(height: 50),
              
                  ElevatedButton(
                    onPressed: () {
                      onStudyDelete();
                      Navigator.pop(context);
                    },
                    child: const Text("Withdraw from study"),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => _showBottomSheetDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            width: 300,
            child: _buildStudyContent(context, flexible: true),
          ),
        ),
      ),
    );
  }
}
