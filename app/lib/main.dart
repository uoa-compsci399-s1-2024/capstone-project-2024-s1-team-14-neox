
// import 'package:capstone_project_2024_s1_team_14_neox/analysis/bloc/analysis_result_bloc.dart';
import 'dart:core';

import 'package:capstone_project_2024_s1_team_14_neox/cloud/cubit/login_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/authentication_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/login_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/sync_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/settings/presentation/settings_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/statistics_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';




// Import bottom navigation screens
import 'child_home/domain/child_device_repository.dart';
import 'child_home/presentation/child_profile_home.dart';
import 'cloud/cubit/cloud_sync_cubit.dart';
import 'cloud/presentation/cloud_home.dart';


// Import blocs and repositories
import 'child_home/cubit/all_child_profile_cubit.dart';
import 'data/database_viewer.dart';

void main() async{
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true); // Used to log BLE
  await dotenv.load();
  AWSServices().initializeStorage();
  await App.initSharedPreferences();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const App(),
    ),
  );
}


class App extends StatelessWidget {
  static late SharedPreferences sharedPreferences;

  static Future<void> initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    //Daily target
    if (sharedPreferences.getInt("daily_target") == null) {
      sharedPreferences.setInt("daily_target", 120);
    }
    // Focus id: key "focus_id"
  }

  static Future<void> resetSharedPreferences() async {
    await sharedPreferences.clear();
    await initSharedPreferences();
  }
  
  const App({super.key});

  Widget _buildLoadingOverlay(BuildContext context, { required Widget child }) {
    return LoaderOverlay(
      useDefaultLoading: false,
      disableBackButton: true,
      overlayColor: Colors.black.withOpacity(0.5),
      overlayWidgetBuilder: (progress) {
        String progressText = "Preparing Sync...";
        if (progress != null) {
          progressText = progress < 1
            ? "Syncing... ${(progress * 100).round()}%"
            : "Classifying...";
        }

        return Center(
          child: Card(
            color: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 30, 50, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(value: progress)
                  ),
                  Text(
                    progressText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

   @override
  Widget build(BuildContext context) {
    // Allows ChildRepository to be accessed anywhere in MyApp
    return RepositoryProvider(
      create: (context) => ChildDeviceRepository(sharedPreferences: sharedPreferences),
      child: MultiBlocProvider(
        // Alows Cubits and Blocs to be accessible anywhere in MyApp
        providers: [
           BlocProvider(
            create: (context) => AllChildProfileCubit(context.read<ChildDeviceRepository>()),
          ),
           BlocProvider(
            create: (context) => CloudSyncCubit(),
          ),
          //  BlocProvider(
          //   create: (context) => LoginCubit(AuthenticationRepository()),
          // ),
        ],
        // Creates MaterialApp
        child: MaterialApp(
          title: 'Neox',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _buildLoadingOverlay(context, child: const MyHomePage(title: 'Neox')),
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
    const StatisticsHome(),
    const CloudHomeScreen(),
    SettingsScreen(),
    const DatabaseViewer(),
    //const RegisterScreen(),
    const LoginScreen(),
    //const ConfirmationPage(email: ''),
    SyncScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider
          .of<ThemeProvider>(context)
          .themeData,
      home: Scaffold(

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
              icon: Icon(Icons.bar_chart),
              label: "Statistics",
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud),
              label: "Cloud",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
            if (kDebugMode)
              NavigationDestination(
                icon: Icon(Icons.table_chart),
                label: "Database",
              ),

          ],
        ),
      ),
    );
  }

}
