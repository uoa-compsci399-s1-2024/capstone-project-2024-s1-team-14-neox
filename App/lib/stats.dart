import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget{
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
            backgroundColor: const Color.fromARGB(204, 181, 81, 255),
      )
    );
  }
}