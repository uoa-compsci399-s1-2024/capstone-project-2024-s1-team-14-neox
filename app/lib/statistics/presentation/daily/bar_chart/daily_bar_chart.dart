import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/daily/bar_chart/bar_chart_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyBarChart extends StatefulWidget {
  final SingleWeekHourlyStatsModel dailySummary;

  const DailyBarChart({super.key, required this.dailySummary});

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  static const List<String> daysShort = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  static const List<String> daysLong = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  int maxValue = 0;
  List<BarChartBar> barData = [];
  List<List<BarChartBar>> dayBreakdownBarData = [[], [], [], [], [], [], []];
  int? selectedDay; // In range [0,6] or null for none

  @override
  void initState() {
    initialiseBarData();
    super.initState();
  }

  void initialiseBarData() {
    int index = 0;
    barData = widget.dailySummary.dailySum.entries.map((e) {
      maxValue = max(maxValue, e.value);
      //return BarChartBar(x: index++, y: Random().nextInt(150), time: e.key);
      return BarChartBar(x: index++, y: e.value, time: e.key);
    }).toList();

    widget.dailySummary.dailyStats.forEach((key, value) {
      int index = 0;
      dayBreakdownBarData[key.weekday - 1] = value.entries
        //.map((e) => BarChartBar(x: index++, y: Random().nextInt(150), time: e.key))
        .map((e) => BarChartBar(x: index++, y: e.value, time: e.key))
        .toList();
    });
  }

  Widget _getDayBottomTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        daysShort[value.toInt()],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _getHourBottomTitles(double value, TitleMeta meta) {
    int val = value.toInt();
    String half = val < 12 ? "AM" : "PM";

    val %= 12;
    if (val == 0) {
      val = 12;
    }

    if (val % 3 != 0) {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        "$val$half",
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _getSideTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    List<BarChartBar> barData,
    {
      required Widget Function(double value, TitleMeta meta) bottomTitles,
      required Color Function(int day) barColour,
      required int sideLabelCount,
      Function(FlTouchEvent event, BarTouchResponse? response)? touchCallback,
      double? barWidth,
    })
  {
    double maxY = max(150, maxValue * 0.2); // TODO Set max depending on maximum of values in y
    double interval = maxY / sideLabelCount;
    
    return Padding(
      padding: const EdgeInsets.all(40),
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,

          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: const Text("Time outdoors (mins)"),
              sideTitles: SideTitles(
                interval: interval,
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: _getSideTitles,
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: bottomTitles,
              ),
            ),
          ),

          barGroups: barData
            .map((data) => BarChartGroupData(
              x: data.x,
              barRods: [BarChartRodData(
                toY: data.y.toDouble(),
                width: barWidth,
                borderRadius: const BorderRadius.all(Radius.zero),
                color: barColour(data.x),
              )],
            ))
            .toList(),

          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  //"${DateFormat("dd MMMM").format(barData[group.x].time)}\n${rod.toY.toInt()} mins",
                  "${rod.toY.toInt()} mins",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
            touchCallback: touchCallback,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startMonday = widget.dailySummary.startMondayDate;
    DateTime endMonday = startMonday.add(const Duration(days: 6));
    String heading = "${DateFormat("d MMMM").format(startMonday)} - ${DateFormat("d MMMM").format(endMonday)}";

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            flex: 2,
            child: _buildBarChart(
              context,
              barData,
              sideLabelCount: 10,
              barWidth: 40,
              bottomTitles: _getDayBottomTitles,
              barColour: (day) {
                if (selectedDay == null || selectedDay == day) {
                  return Theme.of(context).primaryColor;
                } else {
                  return Theme.of(context).primaryColor.withOpacity(0.5);
                }
              },
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                if (event is FlTapDownEvent) {
                  int? select = response?.spot?.touchedBarGroupIndex;
                  if (select != selectedDay) {
                    selectedDay = select;
                    setState(() {});
                  }
                }
              },
            ),
          ),
          
          if (selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${daysLong[selectedDay!]} ${DateFormat("d MMMM").format(startMonday.add(Duration(days: selectedDay!)))}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (selectedDay != null)
            Expanded(
              flex: 1,
              child: _buildBarChart(
                context,
                dayBreakdownBarData[selectedDay!],
                sideLabelCount: 5,
                barColour: (_) => Theme.of(context).primaryColor,
                bottomTitles: _getHourBottomTitles,
              ),
            ),
        ],
      ),
    );
  }
}
