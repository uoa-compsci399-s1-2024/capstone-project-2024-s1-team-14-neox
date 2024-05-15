import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/weekly_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/statistics_cubit.dart';
import 'weekly_bar_graph/weekly_bar_graph.dart';

class WeeklyPanel extends StatefulWidget {
  const WeeklyPanel({super.key});

  @override
  State<WeeklyPanel> createState() => _WeeklyPanelState();
}

class _WeeklyPanelState extends State<WeeklyPanel> {
  // Methods

  // Set current day of interest
  // Calculate number of days since today that is loaded in bloc
  // Future builder for data in bar graph?

  void refreshGraphData() {
    //TODO refresh scroll down
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatisticsCubit, StatisticsState>(
      listener: (context, state) {
        context.read<WeeklyCubit>().onGetDataForChildId(
              context.read<StatisticsCubit>().state.focusChildId,
            );
      },
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.read<WeeklyCubit>().onGetDataForChildId(
                  context.read<StatisticsCubit>().state.focusChildId,
                ),
            child: Text("Refresh"),
          ),
          BlocBuilder<WeeklyCubit, WeeklyState>(
            builder: (context, state) {
              // if (state.status.isInitial) {
              //   return Text("Refresh to get data");
              // }
              return Expanded(
                child: WeeklyBarGraph(
                  dailySummary: state.summary ?? {DateTime.now(): 0},
                  startDay: DateTime.now(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
