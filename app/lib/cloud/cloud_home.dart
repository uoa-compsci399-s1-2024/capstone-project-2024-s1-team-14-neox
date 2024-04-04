import 'package:flutter/material.dart';

class CloudHomeScreen extends StatefulWidget {
  const CloudHomeScreen({super.key});

  @override
  State<CloudHomeScreen> createState() => CloudHomeScreenState();
}

class CloudHomeScreenState extends State<CloudHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect with Neox Cloud"),),
    );
  }
}