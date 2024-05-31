import 'package:capstone_project_2024_s1_team_14_neox/statistics/presentation/daily/daily_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../cubit/daily_cubit.dart';
import '../../cubit/statistics_cubit.dart';

class DailyPanel extends StatefulWidget {
  const DailyPanel({super.key});

  @override
  State<DailyPanel> createState() => _DailyPanelState();
}

class _DailyPanelState extends State<DailyPanel> {
  bool isLoadReady = true;
  final _pageController = PageController(keepPage: false);
  // @override
  // void initState() {
  //   _scrollController.addListener(() {
  //     if (_scrollController.position ==
  //         _scrollController.position.maxScrollExtent) {
  //       print("max scroll extent");
  //     }
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatisticsCubit, StatisticsState>(
        listener: (context, state) {
          // print(context.read<Stat>)
          //context.read<DailyCubit>().onGetDataForChildId(
          //      DateTime.now(),
          //      context.read<StatisticsCubit>().state.focusChildId,
          //    );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<DailyCubit, DailyState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                isLoadReady = true;
                int pageIndex =
                    state.isPastData ? state.dailyStats.length - 4 : 3;
                return Expanded(
                  child: NotificationListener<OverscrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent &&
                          isLoadReady) {
                        setState(() {
                          isLoadReady = false;
                        });
                        context.read<DailyCubit>().onGetPastDataForChildId(
                            context
                                .read<StatisticsCubit>()
                                .state
                                .focusChildId!);
                      } else if (notification.metrics.pixels <=
                              notification.metrics.maxScrollExtent &&
                          isLoadReady) {
                        setState(() {
                          isLoadReady = false;
                        });
                        context.read<DailyCubit>().onGetFutureDataForChildId(
                            context
                                .read<StatisticsCubit>()
                                .state
                                .focusChildId!);
                      }
                      // print(notification);
                      return true;
                    },
                    child: PageView.builder(
                      controller: PageController(initialPage: pageIndex),
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: state.dailyStats.length,
                      itemBuilder: ((context, index) {
                        // if (index == 0 ||
                        //     index == state.dailyStats.length + 1) {
                        //   return CircularProgressIndicator();
                        // }
                        return DailyBarChart(
                          dailySummary: state.dailyStats[index],
                          targetMinutes: state.targetMinutes ?? 120,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ));
  }
}





// PageView(
//             scrollDirection: Axis.horizontal,
//             children: [
//               if (state.summary != null)
//                 ...state.summary!.entries.map(
//                   (e) => Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(DateFormat("dd MMMM").format(e.key)),
//                       CircularPercentIndicator(
//                         radius: 120,
//                         lineWidth: 20,
//                         linearGradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           // end: Alignment.topCenter,
//                           colors: [Colors.blue, Colors.orange],
//                         ),
//                         rotateLinearGradient: true,
//                         backgroundColor: Colors.transparent,
//                         circularStrokeCap: CircularStrokeCap.round,
//                         percent: e.value >= 120 ? 1 : (e.value) / 120,
//                         center: e.value == 1
//                             ? const Text("1 min")
//                             : Text("${e.value} mins"),
//                       ),
//                     ],
//                   ),
//                 )
//             ],
//           );