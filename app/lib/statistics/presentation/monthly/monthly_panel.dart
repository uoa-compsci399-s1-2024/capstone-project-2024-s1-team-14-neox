import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/monthly_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/cubit/statistics_cubit.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/monthly/monthly_bar_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyPanel extends StatelessWidget {
  const MonthlyPanel({super.key});

  Widget _buildWeekHeader() {
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days
          .map((day) => Text(day,
              style: const TextStyle(fontSize: 12, color: Colors.grey)))
          .toList(),
    );
  }

  Widget _buildDateOrIcon(bool isIcon, String text) {
    if (isIcon) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset("assets/icon-small.png"),
      );
    }
    return Text(
      text,
      // style: const TextStyle(
      //   fontWeight: FontWeight.bold,
      // ),
    );
  }

  Widget _buildCalendar(
      DateTime month, Map<DateTime, int>? dailyStats, int targetMinutes) {
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday;
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    DateTime lastDayOfPreviousMonth =
        firstDayOfMonth.subtract(const Duration(days: 1));
    int daysInPreviousMonth = lastDayOfPreviousMonth.day;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            child: GridView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.2,
              ),
              children: days
                  .map((day) => Text(day,
                  textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)))
                  .toList(),
            ),
          ),
          // SizedBox(
          //   height: 20,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     padding: EdgeInsets.zero,
          //     children: days
          //         .map((day) => Text(day,
          //             style: const TextStyle(fontSize: 12, color: Colors.grey)))
          //         .toList(),
          //   ),
          // ),
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
                // if (index < 7) {
                //   return Container(
                //     alignment: Alignment.bottomCenter,
                //     child: Text(
                //       days[index],
                //       style: const TextStyle(fontSize: 12, color: Colors.grey),
                //     ),
                //   );
                if (index < weekdayOfFirstDay - 1) {
                  // Displaying dates from the previous month in grey
                  int previousMonthDay =
                      daysInPreviousMonth - (weekdayOfFirstDay - index) + 2;
                  return Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "", // previousMonthDay.toString(),
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else {
                  // Displaying the current month's days
                  DateTime date = DateTime(
                      month.year, month.month, index - weekdayOfFirstDay + 2);
                  String text = date.day.toString();

                  return Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: _buildDateOrIcon(
                          (dailyStats![date] != null &&
                              dailyStats[date]! >= targetMinutes),
                          text),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context
              .read<MonthlyCubit>()
              .onGetYearDataForChildId(focusYear - 1, focusChild),
        ),
        Text(
          "$focusYear",
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
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

    SingleYearDailyStatsModel? stats =
        context.read<MonthlyCubit>().state.monthlyStats;
    int daysAcheived = stats?.monthlyTargetAcheived[startOfMonth] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat.LLLL().format(startOfMonth),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            // background: Colors.blue,
          ),
        ),
        Text(
            // "Average ${stats?.monthlyMean[startOfMonth]?.floor() ?? 0} mins/day | $daysAcheived ${daysAcheived == 1 ? "day" : "days"} acheived"),
            // Text(
            "Target achieved: $daysAcheived ${daysAcheived == 1 ? "day" : "days"}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screeWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return BlocBuilder<MonthlyCubit, MonthlyState>(
      // buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state.status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        PageController pageController =
            PageController(initialPage: state.focusMonth - 1);
        return Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (context.read<StatisticsCubit>().state.focusChildId != null)
                _buildYearHeader(
                  context,
                  context.read<MonthlyCubit>().state.focusYear,
                  context.read<StatisticsCubit>().state.focusChildId!,
                ),
              Expanded(
                // height: screenHeight * 0.25,
                child: MonthlyBarChart(
                  monthlySummary: state.monthlyStats!,
                  targetMinutes: state.targetMinutes ?? 120,
                  focusMonth: state.focusMonth,
                  pageController: pageController,
                ),
              ),
              const Divider(height: 5, indent: 20, endIndent: 20),
              _buildMonthHeader(context),
              Expanded(
                // height: screenHeight * 0.3,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    return context
                        .read<MonthlyCubit>()
                        .onChangeFocusMonth(index + 1);
                  },
                  itemCount: 12,
                  itemBuilder: (context, pageIndex) {
                    DateTime month =
                        DateTime(state.focusYear, pageIndex + 1, 1);
                    return _buildCalendar(
                      month,
                      state.monthlyStats!.dailyStats[month],
                      state.targetMinutes ?? 120,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
