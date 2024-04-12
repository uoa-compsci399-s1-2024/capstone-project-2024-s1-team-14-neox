import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../child_home/domain/child_device_model.dart';
import '../child_home/cubit/all_child_profile_cubit.dart';
import 'cubit/daily_cubit.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/monthly_cubit.dart';
import 'cubit/weekly_cubit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  //with TickerProviderStateMixin needed for animation
  ChildDeviceModel? _selectedChildProfile;
  late TabController _tabController;

  // TODO update Ui, mighnt not be drop button

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Analysis"),
          actions: [
            DropdownButton<ChildDeviceModel>(
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
                context.read<DashboardCubit>().onFocusChildChange(
                      value?.childId ?? -999,
                    );
              },
            ),
          ],
          bottom:  TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            labelColor: Colors.white,
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BlocProvider(
              create: (context) => DailyCubit(),
              child: Text("daily"),
            ),
            BlocProvider(
              create: (context) => WeeklyCubit(),
              child: Text("weekly"),
            ),
            BlocProvider(
              create: (context) => MonthlyCubit(),
              child: Text("montlhy"),
            ),
          ],
        ),
      ),
    );
  }
}
