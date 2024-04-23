import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/dashboard_repository.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  WeeklyCubit()
      : super(WeeklyState());

  Future<void> onGetDataForChildId(int childId) async {
    emit(state.copyWith(status: WeeklyStatus.loading));

    emit(state.copyWith(
      status: WeeklyStatus.success,
      summary: await DashboardRepository.getDailyOutdoorMinutes(childId),
    ));
  }
}
