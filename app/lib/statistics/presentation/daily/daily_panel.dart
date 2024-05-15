import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../cubit/daily_cubit.dart';
import '../../cubit/statistics_cubit.dart';

class DailyPanel extends StatefulWidget {
  const DailyPanel({super.key});

  @override
  State<DailyPanel> createState() => _DailyPanelState();
}

class _DailyPanelState extends State<DailyPanel> {
  //TODO rebuild only when focus view is the current view
  @override
  Widget build(BuildContext context) {
    return BlocListener<StatisticsCubit, StatisticsState>(
      listener: (context, state) {
        context.read<DailyCubit>().onGetDataForChildId(
              context.read<StatisticsCubit>().state.focusChildId,
            );
      },
      child: BlocBuilder<DailyCubit, DailyState>(
        builder: (context, state) {
          return PageView(
            scrollDirection: Axis.horizontal,
            children: [
              if (state.summary != null)
                ...state.summary!.entries.map(
                  (e) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(DateFormat("dd MMMM").format(e.key)),
                      CircularPercentIndicator(
                        radius: 120,
                        lineWidth: 20,
                        linearGradient: LinearGradient(
                          begin: Alignment.topCenter,
                          // end: Alignment.topCenter,
                          colors: [Colors.blue, Colors.orange],
                        ),
                        rotateLinearGradient: true,
                        backgroundColor: Colors.transparent,
                        circularStrokeCap: CircularStrokeCap.round,
                        percent: e.value >= 120 ? 1 : (e.value) / 120,
                        center: e.value == 1
                            ? const Text("1 min")
                            : Text("${e.value} mins"),
                      ),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
