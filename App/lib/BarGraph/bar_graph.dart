import 'package:capstone_project_2024_s1_team_14_neox/BarGraph/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class MybarGraph extends StatelessWidget{
  final List dailylight;
  const MybarGraph({super.key, required this.dailylight});

  @override
  Widget build(BuildContext context){
    
    BarData myBarData = BarData(
        mon: dailylight[0],
        tue: dailylight[1],
        wed: dailylight[2],
        thur: dailylight[3],
        fri: dailylight[4],
        sat: dailylight[5],
        sun: dailylight[6]
    );
    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        maxY: 500,
           minY: 0,
        barGroups: myBarData.barData
          .map((data) => BarChartGroupData(
            x: data.x,
          barRods: [BarChartRodData(toY: data.y),
          ]
        )
        ).toList(),
      )
    );
  }
}







