import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/statistics_cubit.dart';
import '../../cubit/weekly_cubit.dart';
import 'weekly_bar_graph/weekly_bar_graph.dart';

class WeeklyPanel extends StatefulWidget {
  const WeeklyPanel({super.key});

  @override
  State<WeeklyPanel> createState() => _WeeklyPanelState();
}

class _WeeklyPanelState extends State<WeeklyPanel> {
  @override
  void initState() {
    super.initState();
    _refreshGraphData();
  }

  DateTime getMostRecentMonday() {
    final today = DateTime.now();
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    return today.subtract(Duration(days: daysSinceMonday));
  }

  void _refreshGraphData() {
    final childId = context.read<StatisticsCubit>().state.focusChildId;

    if (childId != null) {
      context.read<WeeklyCubit>().onGetDataForChildId(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatisticsCubit, StatisticsState>(
      listener: (context, state) {
        _refreshGraphData();
      },
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _refreshGraphData,
            child: const Text("Refresh"),
          ),
          Expanded(
            child: BlocBuilder<WeeklyCubit, WeeklyState>(
              builder: (context, state) {
                if (state.status == WeeklyStatus.initial) {
                  return const Center(child: Text("Refresh to get data"));
                } else if (state.status == WeeklyStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == WeeklyStatus.success) {
                  return WeeklyBarGraph(
                    dailySummary: state.summary!,
                    startDay: getMostRecentMonday(),
                  );
                } else if (state.status == WeeklyStatus.failure) {
                  return const Center(child: Text("Failed to load data"));
                } else {
                  return const Center(child: Text("Unknown state"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
