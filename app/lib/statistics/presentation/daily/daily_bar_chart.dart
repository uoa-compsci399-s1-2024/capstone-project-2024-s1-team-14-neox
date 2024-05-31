import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/bar_chart_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyBarChart extends StatefulWidget {
  final SingleWeekHourlyStatsModel dailySummary;
  final int targetMinutes;

  const DailyBarChart(
      {super.key, required this.dailySummary, required this.targetMinutes});

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  static const List<String> daysShort = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];
  static const List<String> daysLong = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

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
    // print(barData);
    widget.dailySummary.hourlyStats.forEach((key, value) {
      int index = 0;
      // print("new month $key");
      dayBreakdownBarData[key.weekday - 1] = value.entries
          //.map((e) => BarChartBar(x: index++, y: Random().nextInt(150), time: e.key))
          .map((e) {
        // print("printing entry $e");
        return BarChartBar(x: index++, y: e.value, time: e.key);
      }).toList();
    });
    // for (List<BarChartBar> oneDay in dayBreakdownBarData) {
    //   print(oneDay);
    // }
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
    String half = val < 12 ? "am" : "pm";


    if (val %2 != 0) {
      return Container();
    }

    // val %= 12;
    // if (val == 0) {
    //   val = 12;
    // }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        val.toString(), //"$val$half",
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
    List<BarChartBar> barData, {
    required Widget Function(double value, TitleMeta meta) bottomTitles,
    required Color Function(int day) barColour,
    required int sideLabelCount,
    required double maxY,
    Function(FlTouchEvent event, BarTouchResponse? response)? touchCallback,
  }) {
    double interval = maxY / sideLabelCount;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                horizontalInterval: widget.targetMinutes.toDouble(),
                checkToShowHorizontalLine: (value) =>
                    value == widget.targetMinutes.toDouble(),
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).colorScheme.secondary,
                    strokeWidth: 4,
                    dashArray: [4, 4]),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  // axisNameWidget: const Text("Time outdoors (mins)"),
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
                        barRods: [
                          BarChartRodData(
                            toY: data.y.toDouble(),
                            width: constraints.maxWidth / (barData.length * 2),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2)),
                            color: barColour(data.x),
                          )
                        ],
                      ))
                  .toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      // "${DateFormat("hh").format(barData[group.x].time)}h ${rod.toY.toInt()} mins",
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
          );
        },
      ),
    );
  }

  double getHourlyMaxY(int value) {
    switch (value) {
      case < 19:
        return 20;
      case < 39:
        return 40;
      default:
        return 60;
    }
  }

  double roundToCeilingFifty(double value) {
    return (value / 50).ceilToDouble() * 50;
  }

  @override
  Widget build(BuildContext context) {
    DateTime startMonday = widget.dailySummary.startMondayDate;
    DateTime endMonday = startMonday.add(const Duration(days: 6));
    Size screenSize = MediaQuery.sizeOf(context);
    double screeWidth = screenSize.width;
    double screenHeight = screenSize.height;
    String heading =
        "${DateFormat("d MMMM").format(startMonday)} - ${DateFormat("d MMMM").format(endMonday)}";

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 18,
              // fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            startMonday.year == endMonday.year
                ? startMonday.year.toString()
                : "${startMonday.year} - ${endMonday.year}",
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildBarChart(
              context,
              barData,
              sideLabelCount: 10,
              maxY: roundToCeilingFifty(
                  max(widget.targetMinutes, maxValue) * 1.2),
              bottomTitles: _getDayBottomTitles,
              barColour: (day) {
                if (selectedDay == null || selectedDay == day) {
                  return Theme.of(context).primaryColor;
                } else {
                  return Theme.of(context).primaryColor.withOpacity(0.5);
                }
              },
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                if (event is FlTapUpEvent) {
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
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Text(
                "${daysLong[selectedDay!]} ${DateFormat("d MMMM").format(startMonday.add(Duration(days: selectedDay!)))}",
                style: const TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (selectedDay != null)
            Expanded(
              flex: 1,
              child: _buildBarChart(
                context,
                dayBreakdownBarData[selectedDay!],
                sideLabelCount: 4,
                maxY: getHourlyMaxY(
                  dayBreakdownBarData[selectedDay!]
                      .fold(0, (prev, data) => max(prev, data.y)),
                ),
                barColour: (_) => Theme.of(context).primaryColor,
                bottomTitles: _getHourBottomTitles,
              ),
            ),
        ],
      ),
    );
  }
}
