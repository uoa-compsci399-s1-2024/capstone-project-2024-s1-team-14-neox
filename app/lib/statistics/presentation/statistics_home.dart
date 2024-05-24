import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/main.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/view_toggle%20copy.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/view_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../child_home/cubit/all_child_profile_cubit.dart';
import '../cubit/daily_cubit.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/monthly_cubit.dart';
import '../cubit/weekly_cubit.dart';
import 'daily/daily_panel.dart';
import 'monthly/monthly_panel.dart';

class StatisticsHome extends StatefulWidget {
  const StatisticsHome({super.key});

  @override
  State<StatisticsHome> createState() => StatisticsHomeState();
}

class StatisticsHomeState extends State<StatisticsHome> {
  bool detailedView = true;
  ChildDeviceModel? _selectedChildProfile;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void animateToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(index,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }
//https://github.com/felangel/bloc/issues/1131
//  Could not find the correct Provider<StatisticsCubit> above this Statistics Widget
// Caused by accessing the bloc from the same BuildContext used to provide it

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          StatisticsRepository(sharedPreferences: App.sharedPreferences),
      child: BlocProvider(
        create: (context) =>
            StatisticsCubit(context.read<StatisticsRepository>()),
        child: Scaffold(
          appBar: AppBar(
            title: BlocBuilder<StatisticsCubit, StatisticsState>(
              builder: (context, state) {
                return DropdownButton<ChildDeviceModel>(
                  value: _selectedChildProfile,
                  items: context
                      .read<AllChildProfileCubit>()
                      .state
                      .profiles
                      .map((profile) => DropdownMenuItem(
                            value: profile,
                            child: Column(
                              children: [
                                Text(profile.childName),
                                // Text(
                                //     "Date of Birth: ${DateFormat('yyyy-MM-dd').format(profile.birthDate)}"),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChildProfile = value;
                    });
                    print("cahing to child id ${value!.childId}");
                    context.read<StatisticsCubit>().onFocusChildChange(
                          value!.childId, //NONNULLABLE Selection
                        );
                  },
                );
              },
            ),
            actions: [
              BlocBuilder<StatisticsCubit, StatisticsState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      print("tapped stats home");
                      context.read<StatisticsCubit>().onFocusViewToggle();
                    },
                    child: ViewToggleReplace(
                      width: 140,
                      height: 40,
                      detailedView:
                          context.read<StatisticsCubit>().state.detailedView,
                    ),
                  );
                },
              )
            ],
            // bottom: TabBar(
            //   indicatorSize: TabBarIndicatorSize.tab,
            //   dividerColor: Colors.transparent,
            //   indicator: BoxDecoration(
            //       color: Theme.of(context).colorScheme.primary,
            //       borderRadius: BorderRadius.all(Radius.circular(10))),
            //   labelColor: Colors.white,
            //   tabs: const [
            //     Tab(text: "Daily"),
            //     Tab(text: "Weekly"),
            //     Tab(text: "Monthly"),
            //   ],
            //   controller: _tabController,
            // ),
          ),
          body: BlocBuilder<StatisticsCubit, StatisticsState>(
              buildWhen: (previous, current) =>
                  previous != current && current is! StatisticsInitial,
              builder: (context, state) {
                print("state for stats home $state");
                if (state is StatisticsOverview) {
                  print("at stats overview home");
                  return BlocProvider(
                    create: (context) =>
                        MonthlyCubit(context.read<StatisticsRepository>())
                          ..onGetYearDataForChildId(
                              DateTime.now().year, state.focusChildId),
                    child: const MonthlyPanel(),
                  );
                } else if (state is StatisticsDetailed) {
                  print("at stats detailed home");
                  return BlocProvider(
                    create: (context) => DailyCubit(
                        context.read<StatisticsRepository>())
                      ..onGetDataForChildId(DateTime.now(), state.focusChildId),
                    child: const DailyPanel(),
                  );
                }
                return Text("Please select a child");
              }),
        ),
      ),
    );
  }
}
