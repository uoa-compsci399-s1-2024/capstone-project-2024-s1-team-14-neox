// Import dependencies
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


// Import bottom navigation screens
import 'analysis/analysis_home.dart';
import 'child_profile/presentation/child_profile_home.dart';
import 'cloud/cloud_home.dart';


// Import blocs and repositories
import 'data/child_repository.dart';
import 'bluetooth/bloc/bluetooth_bloc.dart';
import 'child_profile/cubit/child_profile_cubit.dart';

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
        // Alows Cubits and Blocs to be accessible anywhere in MyApp
        providers: [
          BlocProvider(
            create: (context) => BluetoothBloc(context.read<ChildRepository>()),
          ),
           BlocProvider(
            create: (context) => ChildProfileCubit(context.read<ChildRepository>()),
          ),
        ],
        // Creates MaterialApp
        child: MaterialApp(
          title: 'Neox',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Neox'),
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

  // Screens to navigate to
  List<Widget> body = [
    const ChildHomeScreen(),
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
            label: "Home",
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

