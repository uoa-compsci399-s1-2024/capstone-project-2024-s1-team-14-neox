import 'package:capstone_project_2024_s1_team_14_neox/Entities/childModel.dart';
import 'package:capstone_project_2024_s1_team_14_neox/counter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth/bluetooth_main.dart';



void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true); // Used to log BLE
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

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;


  // The bottom navigation bar loads the Widget for the curretPageIndex
  List<Widget> body = const [ 
    // Pages to navigate to
    CounterScreen(),
    BluetoothScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // Icon and labels for the screes to navigate to
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth),
            label: "Devices",
          ),
        ],  
    ),
   );



  }
}
