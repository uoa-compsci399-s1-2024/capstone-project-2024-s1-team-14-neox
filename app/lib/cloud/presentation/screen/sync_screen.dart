import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/study_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/join_study_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/tiles/study_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                const Text('Join a new study'),
                Text(
                  'Enter the study code.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Study code"),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Join'),
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
    Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud"),
        scrolledUnderElevation: 0,
      ),
      body: RepositoryProvider(
        create: (context) => StudyRepository(),
        child: BlocProvider(
          create: (context) => StudyCubit(context.read<StudyRepository>())
            ..getAllParticipatingStudies(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(40),
                  //     color: Theme.of(context).primaryColor.withOpacity(0.1),
                  //   ),
                  BlocBuilder<CloudSyncCubit, CloudSyncState>(
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return SizedBox(
                          height: 80,
                          child: FilledButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.1))),
                            onPressed: null,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Syncing...',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  const CircularProgressIndicator(),
                                ]),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 80,
                        child: FilledButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.1))),
                          onPressed: () => context
                              .read<CloudSyncCubit>()
                              .uploadAllChildData(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Sync to cloud',
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              Icon(Icons.cloud_upload,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<CloudSyncCubit, CloudSyncState>(
                    builder: (context, state) {
                      return ElevatedButton(
                          onPressed: () => context
                              .read<CloudSyncCubit>()
                              .retrieveChildrenNotInDB(),
                          child: Text(
                            "getting children",
                          ));
                    },
                  ),
                  const Divider(height: 60),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Myopia research",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: BlocConsumer<StudyCubit, StudyState>(
                              listener: (context, state) {
                                if (state.status.isFetchStudySuccess) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) {
                                      return RepositoryProvider.value(
                                        value: context.read<StudyRepository>(),
                                        child: BlocProvider.value(
                                          value: BlocProvider.of<StudyCubit>(
                                              context),
                                          child: JoinStudyScreen(
                                            study: state.newStudy!,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                } else if (state.status.isFailure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.message),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state.status.isLoading) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
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
                          ),
                        ),
                        // onStudyFetch: (studyCode) => Navigator.push(
                        // context,
                        // MaterialPageRoute(builder: (_) {
                        //   return BlocProvider.value(
                        //     value: BlocProvider.of<StudyCubit>(context),
                        //     child: JoinStudyScreen(studyCode: _textFieldController.text.toLowerCase().trim(),),
                        //   );
                        // }
                      ],
                    ),
                  ),
                  BlocBuilder<StudyCubit, StudyState>(
                    builder: (context, state) {
                      print(state.studies);
                      if (state.studies.isEmpty) {
                        return SizedBox(
                          height: screenHeight * 0.3,
                          width: screenWidth * 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "You are not participating in any studies.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Help the researchers at Neox Labs reduce the progress of myopia for children in New Zealand",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _showStudyCodeInputDialog(
                                        context,
                                        onStudyFetch: (s) {
                                          context
                                              .read<StudyCubit>()
                                              .fetchStudyFromServer(s);
                                        },
                                      ),
                                      child: const Text(
                                        'Join',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        children: [
                          ...state.studies.map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: StudyTile(
                                study: s,
                                onStudyDelete: () => context
                                    .read<StudyCubit>()
                                    .withdrawStudy(s.studyCode),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
