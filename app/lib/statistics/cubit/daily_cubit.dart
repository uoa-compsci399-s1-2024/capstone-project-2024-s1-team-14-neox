import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/statistics_repository.dart';

part 'daily_state.dart';

class DailyCubit extends Cubit<DailyState> {
  StatisticsRepository _statisticsRepository;
  DailyCubit(this._statisticsRepository)
      : super(DailyState());

  Future<void> onGetDataForChildId(int childId) async {
    emit(state.copyWith(status: DailyStatus.loading));

    emit(state.copyWith(
      status: DailyStatus.success,
    ));
  }
}
