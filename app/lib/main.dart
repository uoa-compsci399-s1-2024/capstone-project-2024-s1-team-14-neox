// Import dependencies
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


// Import bottom navigation screens
import 'analysis/analysis_home.dart';
import 'child_profile/cubit/child_profile_cubit.dart';
import 'child_profile/presentation/child_profile_home.dart';
import 'cloud/cloud_home.dart';
import 'bluetooth/bluetooth_test_screen.dart';


// Import blocs and repositories
import 'bluetooth/bloc/device_pair_bloc.dart';
import 'data/child_repository.dart';


void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true); // Used to log BLE
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    // Allows ChildRepository to be accessed anywhere in MyApp
    return RepositoryProvider(
      create: (context) => ChildRepository(),
      child: MultiBlocProvider(
        // Alows Cubits and Blocks to be accessible anywhere in MyApp
        providers: [
          BlocProvider(
            create: (context) => DevicePairBloc(context.read<ChildRepository>()),
          ),
           BlocProvider(
            create: (context) => ChildProfileCubit(context.read<ChildRepository>()),
          ),
        ],
        // Creates MaterialApp
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  // The bottom navigation bar loads the Widget for the curretPageIndex
  // Pages to navigate to
  List<Widget> body = [
    const ChildHomeScreen(),
    const BluetoothSyncScreen(),
    const AnalysisHomeScreen(),
    const CloudHomeScreen(),

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
            icon: Icon(Icons.face),
            label: "Profiles",
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth),
            label: "Bluetooth",
          ),
          NavigationDestination(
            icon: Icon(Icons.sunny),
            label: "Analysis",
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload),
            label: "Cloud",
          ),
        ],
      ),
    );
  }
}

