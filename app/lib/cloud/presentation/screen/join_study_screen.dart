import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/participants_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/study_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/tiles/study_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinStudyScreen extends StatefulWidget {
  final StudyModel study;
  const JoinStudyScreen({super.key, required this.study});

  @override
  State<JoinStudyScreen> createState() => _JoinStudyScreenState();
}

class _JoinStudyScreenState extends State<JoinStudyScreen> {
  Map<int, bool?> participatingChildId = {};

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join study"),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StudyInfoTile(widget.study),
              const Divider(height: 50),
              BlocProvider(
                create: (context) =>
                    ParticipantsCubit(context.read<StudyRepository>())
                      ..getAllChildren(),
                child: Column(
                  children: [
                    const Text(
                      "Select participants",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    BlocBuilder<ParticipantsCubit, ParticipantsState>(
                      builder: (context, state) {
                        if (state.status.isLoading) {
                          return const CircularProgressIndicator();
                        }

                        if (state.allChildren.isEmpty) {
                          return const Column(
                            children: [
                              Text(
                                "No profiles no show.",
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Add profiles to participate in the study in the Home tab.",
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30),
                            ],
                          );
                        }

                        return Column(
                          children: state.notParticipating.map((child) {
                            if (!participatingChildId
                                .containsKey(child.childId)) {
                              participatingChildId[child.childId] = false;
                            }
                            return CheckboxListTile(
                              value: participatingChildId[child.childId],
                              title: Text(child.childName),
                              onChanged: (value) => setState(() {
                                participatingChildId[child.childId] = value;
                              }),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<StudyCubit, StudyState>(builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: SizedBox(
                    width: screenWidth,
                    height: 40,
                    child: FilledButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ))),
                      onPressed: () {
                        List<int> selectedChildren = [];
                        participatingChildId.forEach((key, value) {
                          if (value == true) selectedChildren.add(key);
                        });
                        context
                            .read<StudyCubit>()
                            .joinNewStudy(widget.study, selectedChildren);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Join',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
