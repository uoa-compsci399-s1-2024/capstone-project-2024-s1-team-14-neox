import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/bar_chart_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatefulWidget {
  final SingleYearDailyStatsModel monthlySummary;
  const MonthlyBarChart({super.key, required this.monthlySummary});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  static const List<String> monthsShort = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
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
          fontSize: 14,
        ),
      )
    );
  }

  Widget _getSideTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  Widget _buildBarChart() {
    double maxY = max(150, maxValue * 1.2);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return BarChart(
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
                  sideTitles: SideTitles(
                    interval: maxY / 10,
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: _getSideTitles,
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: 1,
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: _getMonthBottomTitles,
                  ),
                ),
              ),

              barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
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

              barGroups: barData.map((data) => BarChartGroupData(
                  x: data.x,
                  barRods: [BarChartRodData(
                    toY: data.y.toDouble(),
                    width: constraints.maxWidth / (barData.length * 2),
                    borderRadius: const BorderRadius.all(Radius.zero),
                    color: Theme.of(context).primaryColor,
                  )]
                ))
                .toList(),
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(
            "Year ${widget.monthlySummary.year}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: _buildBarChart()
          ),
        ],
      ),
    );
  }
}
