import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';

import 'dB/database.dart';

class DatabaseViewer extends StatelessWidget {
  const DatabaseViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Go to Database"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DriftDbViewer(AppDb.instance()))),
              child: Text("Go"))
        ],
      ),
    );
  }
}
