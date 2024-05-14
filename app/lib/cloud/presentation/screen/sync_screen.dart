import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/study_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/join_study_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/tiles/study_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubit/cloud_sync_cubit.dart';

class SyncScreen extends StatelessWidget {
  SyncScreen({super.key});
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _showStudyCodeInputDialog(BuildContext context,
      {required void Function(String) onStudyFetch}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join a New Study'),
                Text(
                  'Enter the study code.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter code"),
            ),
            actions: [
              OutlinedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('JOIN'),
                onPressed: () {
                  onStudyFetch(_textFieldController.text.toLowerCase().trim());
                  _textFieldController.clear();
                  Navigator.pop(context);
                },
                // onPressed: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (_) {
                //       return BlocProvider.value(
                //         value: BlocProvider.of<StudyCubit>(context),
                //         child: JoinStudyScreen(
                //           studyCode:
                //               _textFieldController.text.toLowerCase().trim(),
                //         ),
                //       );
                //     }),
                //   );
                //   // Navigator.pop(context);
                // },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync with Neox Cloud"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Securely store your data and gain insights"),
            ElevatedButton(
              onPressed: () =>
                  context.read<CloudSyncCubit>().syncAllChildData(),
              child: BlocBuilder<CloudSyncCubit, CloudSyncState>(
                builder: (context, state) {
                  if (state.status.isLoading) {
                    return CircularProgressIndicator();
                  }
                  return Text("Sync Device");
                },
              ),
            ),
            BlocBuilder<CloudSyncCubit, CloudSyncState>(
              builder: (context, state) {
                if (state.lastSynced == null) {
                  return Text("");
                }
                return Text(
                    "Last synced: ${DateFormat('yyyy-MM-dd - kk:mm:ss').format(
                  (state.lastSynced as DateTime),
                )}");
              },
            ),
            RepositoryProvider(
              create: (context) => StudyRepository(),
              child: BlocProvider(
                create: (context) => StudyCubit(context.read<StudyRepository>())
                  ..getAllParticipatingStudies(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Participate in Research"),

                        BlocConsumer<StudyCubit, StudyState>(
                          listener: (context, state) {
                            if (state.status.isFetchStudySuccess) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) {
                                  return RepositoryProvider.value(
                                    value: context.read<StudyRepository>(),
                                    child: BlocProvider.value(
                                      value:
                                          BlocProvider.of<StudyCubit>(context),
                                      child: JoinStudyScreen(
                                        study: state.newStudy!,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state.status.isLoading) {
                              return CircularProgressIndicator();
                            }
                            return IconButton(
                              iconSize: 32,
                              icon: const Icon(Icons.add),
                              onPressed: () => _showStudyCodeInputDialog(
                                  context, onStudyFetch: (s) {
                                context
                                    .read<StudyCubit>()
                                    .fetchStudyFromServer(s);
                              }),
                            );
                          },
                        ),
                        // onStudyFetch: (studyCode) => Navigator.push(
                        // context,
                        // MaterialPageRoute(builder: (_) {
                        //   return BlocProvider.value(
                        //     value: BlocProvider.of<StudyCubit>(context),
                        //     child: JoinStudyScreen(studyCode: _textFieldController.text.toLowerCase().trim(),),
                        //   );
                        // }F
                      ],
                    ),
                    BlocBuilder<StudyCubit, StudyState>(
                      builder: (context, state) {
                        if (state.studies.isEmpty) {
                          return Text(
                              "You are not participating in any studies");
                      
                        }
                        return SizedBox(
                          height: 400,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...state.studies.map(
                                (s) => StudyTile(
                                  study: s,
                                  onStudyDelete: () =>
                                      context.read<StudyCubit>().withdrawStudy(s.studyCode),
                                ),
                              ).toList(),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// SizedBox(height: 200),

//           BlocProvider(
//             create: (context) => StudyCubit(StudyRepository()),
//             child: Column(children: [
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Participate in Research"),
//                   IconButton(
//                     iconSize: 32,
//                     icon: Icon(Icons.add),
//                     onPressed: null,
//                   )
//                 ],
//               ),
//               BlocBuilder<StudyCubit, StudyState>(
//                 builder: (context, state) {
//                   return ListView(
//                     scrollDirection: Axis.horizontal,
//                   );
//                 },
//               ),