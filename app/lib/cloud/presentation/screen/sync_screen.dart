import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/study_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubit/cloud_sync_cubit.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync with Neox Cloud"),
      ),
      body: Column(
        children: [
          Text("Securely store your data and gain insights"),
          ElevatedButton(
            onPressed: () => context.read<CloudSyncCubit>().syncAllChildData(),
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
          BlocProvider(
            create: StudyCubit(),
            child: Column(children: [
              Row(children: [
                Text("Research Studies"),
                IconButton(
                  iconSize: 32,
                  icon: Icon(Icons.add),
                  onPressed: null,
                )
              ]),
              BlocBuilder<StudyCubit, StudyState>(
                builder: (context, state) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
