import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/statistics_repository.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  StatisticsRepository _statisticsRepository;
  WeeklyCubit(this._statisticsRepository)
      : super(WeeklyState());

  Future<void> onGetDataForChildId(int childId) async {
    emit(state.copyWith(status: WeeklyStatus.loading));

    emit(state.copyWith(
      status: WeeklyStatus.success,
      summary: await StatisticsRepository.getWeeklyOutdoorMinutes(1),

    ));
  }
}
