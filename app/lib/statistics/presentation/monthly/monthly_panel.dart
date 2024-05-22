import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/monthly_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/statistics_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/monthly/bar_chart/monthly_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyPanel extends StatelessWidget {
  const MonthlyPanel({super.key});

// This widget builds the detailed calendar grid for the chosen month.
  Widget _buildCalendar(DateTime month, Map<DateTime, int>? dailyStats) {
    // Calculating various details for the month's display
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday;

    DateTime lastDayOfPreviousMonth =
        firstDayOfMonth.subtract(Duration(days: 1));
    int daysInPreviousMonth = lastDayOfPreviousMonth.day;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      // Calculating the total number of cells required in the grid
      itemCount: daysInMonth + weekdayOfFirstDay - 1,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirstDay - 1) {
          // Displaying dates from the previous month in grey
          int previousMonthDay =
              daysInPreviousMonth - (weekdayOfFirstDay - index) + 2;
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide.none,
                left: BorderSide.none,
                right: BorderSide.none,
                bottom: BorderSide.none,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              previousMonthDay.toString(),
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else {
          // Displaying the current month's days
          DateTime date =
              DateTime(month.year, month.month, index - weekdayOfFirstDay + 2);
          String text = date.day.toString();

          return InkWell(
            onTap: () {
              // Handle tap on a date cell
              // This is where you can add functionality when a date is tapped
            },
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
              ),
              child: Stack(
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dailyStats![date] != null && dailyStats[date]! >= 120)
                    ImageIcon(AssetImage("assets/icon-small.png"))
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatisticsCubit, StatisticsState>(
        listener: (context, state) {
          // print(context.read<Stat>)
          context.read<MonthlyCubit>().onGetYearDataForChildId(
                DateTime.now().year,
                context.read<StatisticsCubit>().state.focusChildId,
              );
        },
        child: Column(
          children: [
            BlocBuilder<MonthlyCubit, MonthlyState>(
              builder: (context, state) {
                print("State $state");
                if (state.status.isInitial) {
                  print("initial");
                  return Text("Please select a child");
                }
                if (state.status.isLoading){
                  return CircularProgressIndicator();
                }
                return SizedBox(
                  height: 300,
                  child: MonthlyBarChart(monthlySummary: state.monthlyStats!),
                );
              },
            ),
            BlocBuilder<MonthlyCubit, MonthlyState>(
              builder: (context, state) {
                if (state.status.isInitial) {
                  print("initial");
                  return Text("");
                }
                if (state.status.isLoading){
                  return CircularProgressIndicator();
                }
                return SizedBox(
                  height: 300,
                  child: PageView.builder(
                    // controller: _pageController,
                    onPageChanged: (index) =>
                        context.read<MonthlyCubit>().onChangeFocusMonth(index),
                    itemCount: 12,
                    itemBuilder: (context, pageIndex) {
                      DateTime month =
                          DateTime(state.focusYear, pageIndex + 1, 1);
                      return _buildCalendar(
                          month, state.monthlyStats!.dailyStats[month]);
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }
}
