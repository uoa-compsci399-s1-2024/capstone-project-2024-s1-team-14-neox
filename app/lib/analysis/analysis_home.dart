import 'package:flutter/material.dart';

class AnalysisHomeScreen extends StatefulWidget {
  const AnalysisHomeScreen({super.key});

  @override
  State<AnalysisHomeScreen> createState() => AnalysisHomeScreenState();
}

class AnalysisHomeScreenState extends State<AnalysisHomeScreen> {
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analysis"),),
    );
  }
}