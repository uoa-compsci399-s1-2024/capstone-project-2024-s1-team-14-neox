import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void initialiseBarData() {
    int index = 0;
    barData = widget.dailySummary.entries.map((e) {
      return WeeklyIndividualBar(x: index++, y: e.value, date: e.key);
    }).toList();
  }

  Widget _getBottomTitles(DateTime date, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );
    String text = DateFormat("EEEE").format(date).substring(0, 3);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

  Widget _getRightTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double barWidth = 20;
    double spaceBetweenBars = 15;
    initialiseBarData();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width:
            barData.length == 1 ? 300 : barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: 240, // TODO Set max depending on maximum of values in y
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: _getRightTitles,
              )),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  interval: 1,
                  showTitles: true,
                  getTitlesWidget: ((value, meta) {
                    return _getBottomTitles(barData[value.toInt()].date, meta);
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
    );
  }
}
