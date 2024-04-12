import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'weekly_individual_bar.dart';

class WeeklyBarGraph extends StatefulWidget {
  const WeeklyBarGraph({
    super.key,
    required this.dailySummary,
    required this.startDay,
  });
  final Map<DateTime, int> dailySummary;
  final DateTime startDay;

  @override
  State<WeeklyBarGraph> createState() => _WeeklyBarGraphState();
}

class _WeeklyBarGraphState extends State<WeeklyBarGraph> {
  List<WeeklyIndividualBar> barData = [];

  void initialiseBarDate() {
    int index = 0;
    barData = widget.dailySummary.entries.map((e) {
      return WeeklyIndividualBar(x: index ++, y: e.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
      ),
    );
  }
}
