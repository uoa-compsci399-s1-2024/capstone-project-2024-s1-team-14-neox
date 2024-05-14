import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/participants_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/study_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text("Join Research")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.study.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(widget.study.description),
            Text(
              DateFormat("dd MMMM yyyy").format(widget.study.startDate) +
                  "~" +
                  DateFormat("dd MMMM yyyy").format(widget.study.endDate),
              style: const TextStyle(fontSize: 16.0),
            ),
            BlocProvider(
              create: (context) =>
                  ParticipantsCubit(context.read<StudyRepository>())
                    ..getAllChildren(),
              child: Column(
                children: [
                  Text("Select the participating children"),
                  BlocBuilder<ParticipantsCubit, ParticipantsState>(
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return CircularProgressIndicator();
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
            BlocBuilder<StudyCubit, StudyState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    List<int> selectedChildren = [];
                    participatingChildId.forEach((key, value) {
                      if (value == true) selectedChildren.add(key);
                    });
                    context.read<StudyCubit>().joinNewStudy(widget.study, selectedChildren);
                    Navigator.pop(context);
                  },
                  child: Text("Participate"),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
