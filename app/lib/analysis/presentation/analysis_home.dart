import 'package:capstone_project_2024_s1_team_14_neox/analysis/bloc/analysis_result_bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/child_home/cubit/all_child_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/domain/child_device_model.dart';

class AnalysisHomeScreen extends StatefulWidget {
  const AnalysisHomeScreen({super.key});

  @override
  State<AnalysisHomeScreen> createState() => AnalysisHomeScreenState();
}

class AnalysisHomeScreenState extends State<AnalysisHomeScreen> {
    ChildDeviceModel? _selectedChildProfile;
  // TODO update Ui, mighnt not be drop button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analysis"),
      ),
      body: Column(
        children: [
          DropdownButton<ChildDeviceModel>(
            value: _selectedChildProfile,
            items: context
                .read<AllChildProfileCubit>()
                .state
                .profiles
                .map((profile) => DropdownMenuItem(
                      value: profile,
                      child: Column(
                        children: [
                          Text(profile.childName),
                          Text(
                            profile.birthDate.toString(),
                          )
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedChildProfile = value;
                context.read<AnalysisBloc>().add(
                      AnalysisChangeChildEvent(
                        childId: value?.childId ?? -999,
                      ),
                    );
              });
            },
          ),
          ElevatedButton(
            onPressed: () => context.read<AnalysisBloc>().add(
                  AnalysisLoadDataEvent(
                    childId: context.read<AnalysisBloc>().state.focusChildId,
                  ),
                ),
            child: const Text("Refresh"),
          ),
          BlocConsumer<AnalysisBloc, AnalysisState>(
            listener: (context, state) {
              // TODO: implement listener if needed
            },
            builder: (context, state) {
              if (state.status.isLoading) {
                return CircularProgressIndicator();
              } else if (state.status.isInitial) {
                return Text("Refresh to fetch data");
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ExpansionTile(
                      title: Text(state.data[index].dateTime.toString()),
                      children: [
                        Text("Light: ${state.data[index].light}"),
                        Text("UV: ${state.data[index].uv}"),
                        Text("Accelerator X: ${state.data[index].accelX}"),
                        Text("Accelerator Y: ${state.data[index].accelY}"),
                        Text("Accelerator Z: ${state.data[index].accelZ}"),
                      ],
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}