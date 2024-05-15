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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud"),
        scrolledUnderElevation: 0,
      ),
      body: RepositoryProvider(
        create: (context) => StudyRepository(),
        child: BlocProvider(
          create: (context) => StudyCubit(context.read<StudyRepository>())..getAllParticipatingStudies(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      children: [
                        const Text(
                          "Sync your data to the cloud",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),
                    
                        // BlocBuilder<CloudSyncCubit, CloudSyncState>(
                        //   builder: (context, state) {
                        //     if (state.lastSynced == null) {
                        //       return const Text("Last synced: never");
                        //     }
                        //     return Text("Last synced: ${DateFormat('yyyy-MM-dd - kk:mm:ss').format(state.lastSynced!)}");
                        //   },
                        // ),
                        
                        // const Spacer(),
                        
                        ElevatedButton(
                          onPressed: () => context.read<CloudSyncCubit>().syncAllChildData(),
                          child: BlocBuilder<CloudSyncCubit, CloudSyncState>(
                            builder: (context, state) {
                              if (state.status.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              return const Icon(Icons.cloud_upload, color: Colors.black);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 80),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Participate in a study",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

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
                          return const CircularProgressIndicator();
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
                      return Container();
                    }
                    return Expanded(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          ...state.studies.map(
                            (s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: StudyTile(
                                study: s,
                                onStudyDelete: () => context.read<StudyCubit>().withdrawStudy(s.studyCode),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
