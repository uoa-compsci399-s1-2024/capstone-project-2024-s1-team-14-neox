import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/main.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
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

  @override
  void initState() {
    int? childId = App.sharedPreferences.getInt("focus_id");
    _selectedChildProfile = context
        .read<AllChildProfileCubit>()
        .state
        .profiles
        .where((element) => element.childId == childId)
        .firstOrNull;
    super.initState();
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
              return InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  prefixIcon: const Icon(
                    Icons.face,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.background,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ChildDeviceModel>(
                    isExpanded: true,
                    value: _selectedChildProfile,
                    icon: const Padding(
                      padding:  EdgeInsets.only(right: 4.0),
                      child:  Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ),
                    iconSize: 24,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    items: context
                        .read<AllChildProfileCubit>()
                        .state
                        .profiles
                        .map(
                          (profile) => DropdownMenuItem(
                            value: profile,
                            child: Text(profile.childName, overflow: TextOverflow.fade,),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedChildProfile = value;
                      });
                      context
                          .read<StatisticsCubit>()
                          .onFocusChildChange(value!.childId);
                    },
                  ),
                ),
              );
            }),
            actions: [
              BlocBuilder<StatisticsCubit, StatisticsState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      context.read<StatisticsCubit>().onFocusViewToggle();
                    },
                    child: ViewToggle(
                      width: 140,
                      height: 40,
                      detailedView: context.read<StatisticsCubit>().state
                          is DetailedStatisticsState,
                    ),
                  );
                },
              )
            ],
          ),
          body: BlocBuilder<StatisticsCubit, StatisticsState>(
              builder: (context, state) {
            if (state.focusChildId == null) {
              return const Center(
                child: Text("Select a profile to view statistics"),
              );
            }

            if (state is OverviewStatisticsState) {
              return BlocProvider(
                key: UniqueKey(), // Workaround for refreshing UI!
                create: (context) =>
                    MonthlyCubit(context.read<StatisticsRepository>())
                      ..onGetYearDataForChildId(
                          DateTime.now().year, state.focusChildId!),
                child: const MonthlyPanel(),
              );
            } else {
              return BlocProvider(
                key: UniqueKey(), // Workaround for refreshing UI!
                create: (context) =>
                    DailyCubit(context.read<StatisticsRepository>())
                      ..onGetPastDataForChildId(state.focusChildId!),
                child: const DailyPanel(),
              );
            }
          }),
        ),
      ),
    );
  }
}
