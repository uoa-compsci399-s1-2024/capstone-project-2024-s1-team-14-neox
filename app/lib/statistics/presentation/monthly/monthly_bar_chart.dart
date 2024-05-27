import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/monthly_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/bar_chart_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatefulWidget {
  final SingleYearDailyStatsModel monthlySummary;
  final int targetMinutes;
  final int focusMonth;
  final PageController pageController;
  const MonthlyBarChart(
      {super.key,
      required this.monthlySummary,
      required this.targetMinutes,
      required this.focusMonth,
      required this.pageController});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  static const List<String> monthsShort = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  double maxValue = 0;
  List<BarChartBar> barData = [];

  @override
  void initState() {
    initialiseBarData();
    super.initState();
  }

  void initialiseBarData() {
    int index = 0;
    barData = widget.monthlySummary.monthlyMean.entries.map((e) {
      maxValue = max(maxValue, e.value);
      //return BarChartBar(x: index++, y: Random().nextInt(200), time: e.key);
      return BarChartBar(x: index++, y: e.value.toInt(), time: e.key);
    }).toList();
  }

  Widget _getMonthBottomTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          monthsShort[value.toInt()],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ));
  }

  Widget _getSideTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  double _roundToCeilingFifty(double value) {
    return (value / 50).ceilToDouble() * 50;
  }

  Widget _buildBarChart() {
    double maxY =
        _roundToCeilingFifty(max(widget.targetMinutes, maxValue) * 1.1);
    return Padding(
      padding: const EdgeInsets.all(10),
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
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    dashArray: [8, 4]),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: maxY / 10,
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: _getSideTitles,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: 1,
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: _getMonthBottomTitles,
                  ),
                ),
              ),
              barTouchData: BarTouchData(touchCallback:
                  (FlTouchEvent event, BarTouchResponse? touchResponse) {
                if (event is FlTapUpEvent) {
                  int? selectedMonthIndex =
                      touchResponse?.spot?.touchedBarGroupIndex;
                  if (selectedMonthIndex != null) {
                    widget.pageController.jumpToPage(selectedMonthIndex);
                    context
                        .read<MonthlyCubit>()
                        .onChangeFocusMonth(selectedMonthIndex + 1);
                  }
                }
              }, touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "${DateFormat("MMMM").format(barData[group.x].time)}\n${rod.toY.toInt()} mins",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              )),
              barGroups: barData
                  .map((data) => BarChartGroupData(x: data.x, barRods: [
                        BarChartRodData(
                          toY: data.y.toDouble(),
                          width: constraints.maxWidth / (barData.length * 2),
                          borderRadius: const BorderRadius.all(Radius.zero),
                          // color: Colors.blue,
                          color: data.x == widget.focusMonth - 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                        )
                      ]))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildBarChart()),
      ],
    );
  }
}
