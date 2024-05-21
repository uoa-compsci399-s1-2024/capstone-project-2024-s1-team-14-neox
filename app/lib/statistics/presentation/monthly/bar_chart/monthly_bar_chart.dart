import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/monthly/bar_chart/monthly_individual_bar.dart';
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
  double maxValue = 0;
  List<MonthlyIndividualBar> barData = [];

  void initialiseBarData() {
    int index = 0;
    barData = widget.monthlySummary.monthlyMean.entries.map((e) {
      maxValue = max(maxValue, e.value);
      return MonthlyIndividualBar(x: index++, y: e.value, month: e.key);
    }).toList();
  }

  Widget _getMonthBottomTitles(double value, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = "Jan";
        break;
      case 1:
        text = "Feb";
        break;
      case 2:
        text = "Mar";
        break;
      case 3:
        text = "Apr";
        break;
      case 4:
        text = "May";
        break;
      case 5:
        text = "Jun";
        break;
      case 6:
        text = "Jul";
        break;
      case 7:
        text = "Aug";
        break;
      case 8:
        text = "Sep";
        break;
      case 9:
        text = "Oct";
        break;
      case 10:
        text = "Nov";
        break;
      case 11:
        text = "Dec";
        break;
      default:
        text = "";
        break;
    }
    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          text,
          style: textStyle,
        ));
  }

  Widget _getSideTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: max(150,
            maxValue * 0.2), // TODO Set max depending on maximum of values in y
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: _getSideTitles,
          )),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 1,
              showTitles: true,
              getTitlesWidget: ((value, meta) {
                return _getMonthBottomTitles(value, meta);
              }),
            ),
          ),
        ),
        barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (
            group,
            groupIndex,
            rod,
            rodIndex,
          ) {
            return BarTooltipItem(
                "${DateFormat("MMMM").format(barData[group.x].month)}\n${rod.toY.toInt()} mins",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ));
          },
        )),
        barGroups: barData
            .map(
              (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [BarChartRodData(toY: data.y)]),
            )
            .toList(),
      ),
    );
  }
}
