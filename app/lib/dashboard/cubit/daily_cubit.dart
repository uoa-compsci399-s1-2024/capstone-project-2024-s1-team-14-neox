import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/dashboard_repository.dart';

part 'daily_state.dart';

class DailyCubit extends Cubit<DailyState> {
  DailyCubit()
      : super(DailyState());

  void onGetDataForChildId(int childId) {
    emit(state.copyWith(status: DailyStatus.loading));

    emit(state.copyWith(
      status: DailyStatus.success,
      summary: DashboardRepository.getDataForChildId(childId),
    ));
  }
}
