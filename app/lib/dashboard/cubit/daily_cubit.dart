import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/dashboard_repository.dart';

part 'daily_state.dart';

class DailyCubit extends Cubit<DailyState> {
  DailyCubit()
      : super(DailyState());

  Future<void> onGetDataForChildId(int childId) async {
    emit(state.copyWith(status: DailyStatus.loading));

    emit(state.copyWith(
      status: DailyStatus.success,
      summary: await DashboardRepository.getDailyOutdoorMinutes(childId),
    ));
  }
}
