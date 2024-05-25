import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/monthly_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/statistics_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/monthly/monthly_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyPanel extends StatelessWidget {
  const MonthlyPanel({super.key});
  Widget _buildWeekHeader() {
    const List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days
        .map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold)))
        .toList(),
    );
  }

  Widget _buildCalendar(
      DateTime month, Map<DateTime, int>? dailyStats, int targetMinutes) {
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday;

    DateTime lastDayOfPreviousMonth =
        firstDayOfMonth.subtract(Duration(days: 1));
    int daysInPreviousMonth = lastDayOfPreviousMonth.day;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildWeekHeader(),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
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
                  DateTime date = DateTime(
                      month.year, month.month, index - weekdayOfFirstDay + 2);
                  String text = date.day.toString();
            
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide.none,
                        left: BorderSide.none,
                        right: BorderSide.none,
                        bottom: BorderSide.none,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (dailyStats![date] != null &&
                            dailyStats[date]! >= targetMinutes)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                            child: Image.asset("assets/icon-small.png"),
                          )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearHeader(BuildContext context, int focusYear, int focusChild) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context
              .read<MonthlyCubit>()
              .onGetYearDataForChildId(focusYear - 1, focusChild),
        ),
        Text(
          "$focusYear",
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () => context
              .read<MonthlyCubit>()
              .onGetYearDataForChildId(focusYear + 1, focusChild),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    DateTime startOfMonth = DateTime(
      context.read<MonthlyCubit>().state.focusYear,
      context.read<MonthlyCubit>().state.focusMonth,
      1,
    );

    SingleYearDailyStatsModel? stats = context.read<MonthlyCubit>().state.monthlyStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat.LLLL().format(startOfMonth),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text("Average ${stats?.monthlyMean[startOfMonth]?.floor() ?? 0} mins/day"),
        Text("Targets achieved: ${stats?.monthlyTargetAcheived[startOfMonth] ?? 0}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyCubit, MonthlyState>(
      builder: (context, state) {
        if (state.status.isLoading) {
            return const Center(child: CircularProgressIndicator());
        }
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              if (context.read<StatisticsCubit>().state.focusChildId != null)
              _buildYearHeader(
                context,
                context.read<MonthlyCubit>().state.focusYear,
                context.read<StatisticsCubit>().state.focusChildId!,
              ),
              Expanded(
                flex: 1,
                child: MonthlyBarChart(monthlySummary: state.monthlyStats!),
              ),

              const Divider(height: 20, indent: 20, endIndent: 20),

              _buildMonthHeader(context),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 300,
                  child: PageView.builder(
                    // controller: _pageController,
                    onPageChanged: (index) =>
                        context.read<MonthlyCubit>().onChangeFocusMonth(index),
                    itemCount: 12,
                    itemBuilder: (context, pageIndex) {
                      DateTime month = DateTime(state.focusYear, pageIndex + 1, 1);
                      return _buildCalendar(month, state.monthlyStats!.dailyStats[month], state.targetMinutes ?? 120);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
