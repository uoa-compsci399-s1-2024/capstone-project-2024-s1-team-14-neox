import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_model.dart';
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
import 'weekly/weekly_panel.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => DashboardHomeState();
}

class DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  //with TickerProviderStateMixin needed for animation
  ChildDeviceModel? _selectedChildProfile;
  late TabController _tabController;

  // TODO update Ui, mighnt not be drop button

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

//https://github.com/felangel/bloc/issues/1131
//  Could not find the correct Provider<StatisticsCubit> above this Dashboard Widget
// Caused by accessing the bloc from the same BuildContext used to provide it
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticsCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Analysis"),
          actions: [
            BlocBuilder<StatisticsCubit, StatisticsState>(
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
                                Text("Name: ${profile.childName}"),
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
                    context.read<StatisticsCubit>().onFocusChildChange(
                          value!.childId, //NONNULLABLE Selection
                        );
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            labelColor: Colors.white,
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
            controller: _tabController,
          ),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => DailyCubit()),
            BlocProvider(create: (_) => WeeklyCubit()),
            BlocProvider(create: (_) => MonthlyCubit()),
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              DailyPanel(),
              WeeklyPanel(),
              MonthlyPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
