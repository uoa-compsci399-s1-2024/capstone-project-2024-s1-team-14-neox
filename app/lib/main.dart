import 'package:capstone_project_2024_s1_team_14_neox/analysis/bloc/analysis_result_bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/dashboard/presentation/dashboard_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:loader_overlay/loader_overlay.dart';


// Import bottom navigation screens
import 'analysis/presentation/analysis_home.dart';
import 'child_home/domain/child_device_repository.dart';
import 'child_home/presentation/child_profile_home.dart';
import 'cloud/presentation/cloud_home.dart';


// Import blocs and repositories
import 'child_home/cubit/all_child_profile_cubit.dart';
import 'data/database_viewer.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true); // Used to log BLE
  runApp(const MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _buildLoadingOverlay({ required Widget child }) {
    return Material(
      color: Colors.transparent,
      child: LoaderOverlay(
        useDefaultLoading: false,
        overlayColor: Colors.black.withOpacity(0.5),
        overlayWidgetBuilder: (progress) {
          return Center(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              child: Padding(padding: EdgeInsets.fromLTRB(50, 30, 50, 30), child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                  Text(
                    progress == null ? "Authenticating..." : "Syncing ... ${(progress * 100).round()}%",
                    style: const TextStyle(color: Colors.deepPurple, fontSize: 20)
                  ),
                ],
              )),
            ),
          );
        },
        child: child,
      )
    );
  }

   @override
  Widget build(BuildContext context) {
    // Allows ChildRepository to be accessed anywhere in MyApp
    return RepositoryProvider(
      create: (context) => ChildDeviceRepository(),
      child: MultiBlocProvider(
        // Alows Cubits and Blocs to be accessible anywhere in MyApp
        providers: [
           BlocProvider(
            create: (context) => AllChildProfileCubit(context.read<ChildDeviceRepository>()),
          ),
        ],
        // Creates MaterialApp
        child: MaterialApp(
          title: 'Neox',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _buildLoadingOverlay(child: const MyHomePage(title: 'Neox')),
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
    // const AnalysisHomeScreen(),
    BlocProvider(
      create: (context) => AnalysisBloc(),
      child: AnalysisHomeScreen(),
    ),
    const DashboardHome(),
    const CloudHomeScreen(),
    const DatabaseViewer(),

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
            label: "Sensor",
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload),
            label: "Cloud",
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart),
            label: "Database",
          ),
        ],
      ),
    );
  }
}

