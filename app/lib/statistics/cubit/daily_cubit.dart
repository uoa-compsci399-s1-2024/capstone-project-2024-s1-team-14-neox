import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/statistics_repository.dart';

part 'daily_state.dart';

class DailyCubit extends Cubit<DailyState> {
  final StatisticsRepository _statisticsRepository;
  DailyCubit(this._statisticsRepository)
      : super(DailyState(
          targetMinutes: _statisticsRepository.getDailyTarget(),
          isPastData: true,
        ));

  DateTime _getMondayMidnight(DateTime date) {
    // get Monday date
    date = date.subtract(Duration(days: date.weekday - 1));
    // reset to midnight
    date = DateTime(date.year, date.month, date.day);
    return date;
  }

  Future<void> onGetPastDataForChildId(int childId) async {
    emit(state.copyWith(status: DailyStatus.loading));
    await Future.delayed(const Duration(milliseconds: 200));
    DateTime startMonday =
        state.earliestMonday ?? _getMondayMidnight(DateTime.now());

    DateTime earliestMonday = startMonday.subtract(const Duration(days: 28));
    List<SingleWeekHourlyStatsModel> newDailyStats = await _statisticsRepository
        .getListOfHourlyStats(startMonday, 4, childId);
    // print(newDailyStats[0]);
    if (isClosed) {
      return;
    }
    emit(state.copyWith(
      status: DailyStatus.success,
      dailyStats: state.dailyStats + newDailyStats,
      earliestMonday: earliestMonday,
      isPastData: true,
    ));
  }

  Future<void> onGetFutureDataForChildId(int childId) async {
    emit(state.copyWith(status: DailyStatus.loading));
    await Future.delayed(const Duration(milliseconds: 200));
    DateTime startMonday =
        state.latestMonday ?? _getMondayMidnight(DateTime.now());
    DateTime latestMonday = startMonday.add(const Duration(days: 28));

    List<SingleWeekHourlyStatsModel> newDailyStats = await _statisticsRepository
        .getListOfHourlyStats(latestMonday, 4, childId);
    // print(newDailyStats[0]);
    if (isClosed) {
      return;
    }
    emit(state.copyWith(
      status: DailyStatus.success,
      dailyStats: newDailyStats + state.dailyStats,
      latestMonday: latestMonday,
      isPastData: false,
    ));
  }
}
