import 'package:flutter/material.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync with Neox Cloud"),
      ),
      body: Column(
        children: [
          Text("Securely store your data and gain insights"),
          ElevatedButton(
            onPressed: null,
            child: const Text("Sync"),
          )
        ],
      ),
    );
  }
}
