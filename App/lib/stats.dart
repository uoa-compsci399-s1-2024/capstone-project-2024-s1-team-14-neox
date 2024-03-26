import 'package:capstone_project_2024_s1_team_14_neox/BarGraph/bar_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';



class StatsPage extends StatelessWidget{
  const StatsPage({super.key});



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
            backgroundColor: const Color.fromARGB(204, 181, 81, 255),
      ),
      body: Center(
          child: SizedBox(
            height: 400,
              child:
              MybarGraph(dailylight: [  100.00,
                200.00,
                300.00,
                400.00,
                110.00,
                434.00,
                123.00,],))),
    );


  }
}