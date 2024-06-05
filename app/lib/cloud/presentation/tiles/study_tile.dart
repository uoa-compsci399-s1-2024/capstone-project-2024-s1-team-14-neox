import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/participants_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/tiles/study_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudyTile extends StatelessWidget {
  final StudyModel study;
  final VoidCallback onStudyDelete;

  const StudyTile(
      {super.key, required this.study, required this.onStudyDelete});

  Widget _buildParticipationList(
      BuildContext context, ParticipantsState state) {
    return Column(
      children: [
        const Text(
          "Manage participants",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        if (state.allChildren.isEmpty) ...const [
          Text(
            "No profiles no show.",
            textAlign: TextAlign.center,
          ),
          Text(
            "Add profiles to participate in the study from the home tab.",
            textAlign: TextAlign.center,
          ),
        ],
        ...state.allChildren.map((child) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  child.childName,
                  style: const TextStyle(fontSize: 18),
                ),
                state.participating
                        .any((other) => other.childId == child.childId)
                    ? IconButton(
                        iconSize: 32,
                        onPressed: () => context
                            .read<ParticipantsCubit>()
                            .deleteChildFromStudy(
                                child.childId, study.studyCode),
                        icon: const Icon(
                          Icons.person_remove,
                          color: Colors.red,
                        ))
                    : IconButton(
                        iconSize: 32,
                        onPressed: () => context
                            .read<ParticipantsCubit>()
                            .addChildToStudy(child.childId, study.studyCode),
                        icon: const Icon(
                          Icons.person_add_alt_1,
                        ),
                      ),
              ],
            ))
      ],
    );
  }

  void _showWithdrawConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Withdraw from study?'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onStudyDelete();
              Navigator.pop(innerContext);
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showBottomSheetDialog(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StudyInfoTile(study, showCode: true),
                  const Divider(height: 50),
                  BlocProvider(
                    create: (_) =>
                        ParticipantsCubit(context.read<StudyRepository>())
                          ..getParticipatingStatus(study.studyCode),
                    child: BlocBuilder<ParticipantsCubit, ParticipantsState>(
                      builder: (context, state) {
                        if (state.status.isLoading) {
                          return const CircularProgressIndicator();
                        }
                        return _buildParticipationList(context, state);
                      },
                    ),
                  ),
                  const Divider(height: 50),
                  SizedBox(
                    width: screenWidth,
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showWithdrawConfirmDialog(context),
                      child: const Text(
                        'Withdraw from study',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
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
            child: StudyInfoTile(study, flexible: true),
          ),
        ),
      ),
    );
  }
}
