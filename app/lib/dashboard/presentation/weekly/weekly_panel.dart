import 'package:capstone_project_2024_s1_team_14_neox/dashboard/cubit/weekly_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'weekly_bar_graph/weekly_bar_graph.dart';

class WeeklyPanel extends StatefulWidget {
  const WeeklyPanel({super.key});

  @override
  State<WeeklyPanel> createState() => _WeeklyPanelState();
}

class _WeeklyPanelState extends State<WeeklyPanel> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        return WeeklyBarGraph(
          dailySummary: state.summary ?? {DateTime.now(): 0},
          startDay: DateTime.now(),
        );
      },
    );
  }
}
