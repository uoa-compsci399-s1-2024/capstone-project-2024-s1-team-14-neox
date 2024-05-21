import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/daily/bar_chart/hourly_individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'daily_individual_bar.dart';

class DailyBarChart extends StatefulWidget {
  final SingleWeekHourlyStatsModel dailySummary;

  const DailyBarChart({super.key, required this.dailySummary});

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  int maxValue = 0;
  List<DailyIndividualBar> barData = [];
  List<HourlyIndividualBar> monBarData = [];
  List<HourlyIndividualBar> tueBarData = [];
  List<HourlyIndividualBar> wedBarData = [];
  List<HourlyIndividualBar> thuBarData = [];
  List<HourlyIndividualBar> friBarData = [];
  List<HourlyIndividualBar> satBarData = [];
  List<HourlyIndividualBar> sunBarData = [];

  void initialiseBarData() {
    int index = 0;
    barData = widget.dailySummary.dailySum.entries.map((e) {
      maxValue = max(maxValue, e.value);
      return DailyIndividualBar(x: index++, y: e.value, date: e.key);
    }).toList();
    widget.dailySummary.dailyStats.forEach((key, value) {
      if (key.weekday == 1) {
        int indexMon = 0;
        monBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexMon++, y: e.value, hour: e.key);
        }).toList();
      } else if (key.weekday == 2) {
        int indexTue = 0;
        tueBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexTue++, y: e.value, hour: e.key);
        }).toList();
      } else if (key.weekday == 3) {
        int indexWed = 0;
        wedBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexWed++, y: e.value, hour: e.key);
        }).toList();
      } else if (key.weekday == 4) {
        int indexThu = 0;
        thuBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexThu++, y: e.value, hour: e.key);
        }).toList();
      } else if (key.weekday == 5) {
        int indexFri = 0;
        friBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexFri++, y: e.value, hour: e.key);
        }).toList();
      } else if (key.weekday == 6) {
        int indexSat = 0;
        satBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexSat++, y: e.value, hour: e.key);
        }).toList();
      } else {
        int indexSun = 0;
        sunBarData = value.entries.map((e) {
          return HourlyIndividualBar(x: indexSun++, y: e.value, hour: e.key);
        }).toList();
      }
    });
  }

  Widget _getDayBottomTitles(double value, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = "MON";
        break;
      case 1:
        text = "TUE";
        break;
      case 2:
        text = "WED";
        break;
      case 3:
        text = "THU";
        break;
      case 4:
        text = "FRI";
        break;
      case 5:
        text = "SAT";
        break;
      case 6:
        text = "SUN";
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

  Widget _getHourBottomTitles(double value, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );

    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          "${value}h",
          style: textStyle,
        ));
  }

  // Widget _getDayBottomTitles(DateTime date, TitleMeta meta) {
  //   const textStyle = TextStyle(
  //     color: Colors.grey,
  //     fontSize: 14,
  //   );
  //   String text = DateFormat("EEEE").format(date).substring(0, 3);
  //   return SideTitleWidget(
  //     axisSide: meta.axisSide,
  //     child: Text(
  //       text,
  //       style: textStyle,
  //     ),
  //   );
  // }

  Widget _getSideTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  SizedBox _buildHourlyChart(List<HourlyIndividualBar> hourlyBarData) {
    return SizedBox(
      height: 100,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 60,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                getTitlesWidget: ((value, meta) {
                  return _getHourBottomTitles(value, meta);
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
                  "${group.x}h\n${rod.toY.toInt()} mins",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ));
            },
          )),
          barGroups: hourlyBarData
              .map(
                (data) => BarChartGroupData(
                    x: data.x,
                    barRods: [BarChartRodData(toY: data.y.toDouble())]),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initialiseBarData();
    return Column(
      children: [
        Text("Daily outdoor time"),
        Expanded(
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: max(
                  150,
                  maxValue *
                      0.2), // TODO Set max depending on maximum of values in y
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
                      return _getDayBottomTitles(value, meta);
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
                      "${DateFormat("dd MMMM").format(barData[group.x].date)}\n${rod.toY.toInt()} mins",
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
                        barRods: [BarChartRodData(toY: data.y.toDouble())]),
                  )
                  .toList(),
            ),
          ),
        ),
        Text("Hourly breakdown"),
        Text("Monday"),
        _buildHourlyChart(monBarData),
        Text("Tuesday"),
        _buildHourlyChart(tueBarData),
        Text("Wednesday"),
        _buildHourlyChart(wedBarData),
        Text("Thursday"),
        _buildHourlyChart(thuBarData),
        Text("Friday"),
        _buildHourlyChart(friBarData),
        Text("Saturday"),
        _buildHourlyChart(satBarData),
        Text("Sunday"),
        _buildHourlyChart(sunBarData),
      ],
    );
  }
}
