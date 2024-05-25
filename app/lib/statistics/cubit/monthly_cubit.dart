import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_year_daily_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:equatable/equatable.dart';

part 'monthly_state.dart';

class MonthlyCubit extends Cubit<MonthlyState> {
  final StatisticsRepository _statisticsRepository;

  MonthlyCubit(this._statisticsRepository)
      : super(MonthlyState(focusYear: DateTime.now().year, focusMonth: DateTime.now().month));

  Future<void> onGetYearDataForChildId(int year, int childId) async {
    emit(MonthlyState(status: MonthlyStatus.loading, focusYear: state.focusYear, focusMonth: state.focusMonth));
    await Future.delayed(const Duration(milliseconds: 500));
    SingleYearDailyStatsModel newMonthlyStats = await _statisticsRepository.getSingleYearDailyStats(year, childId);
    if (isClosed) {
      return;
    }

    emit(state.copyWith(
      status: MonthlyStatus.success,
      focusYear: year,
      monthlyStats: newMonthlyStats,
    ));
  }

  void onChangeFocusMonth(int pageIndex) {
    emit(state.copyWith(
      focusMonth: pageIndex + 1,
    ));
  }
}
