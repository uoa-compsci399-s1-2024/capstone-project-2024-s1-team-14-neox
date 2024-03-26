import 'package:capstone_project_2024_s1_team_14_neox/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routes: {
        '/Stats': (context) => const StatsPage(),
      },
      home: MyHomePage(),
    );

  }
}

class MyHomePage extends StatelessWidget {

 // Amount of light exposure in a day





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(204, 181, 81, 255),
      ),

      body: Column(

        children: [
          Home(),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Stats');
              },

              child:
              Text("Statistics")
          )
        ]
      ),
    );
  }


}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
        padding: EdgeInsets.all(20),
        child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset('Assets/Assets/neox-sens-horizontal.svg', height: 200,)
    ]
        )
    );
  }
}

