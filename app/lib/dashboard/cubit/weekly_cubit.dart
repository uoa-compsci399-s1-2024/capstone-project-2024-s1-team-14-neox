import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/dashboard_repository.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  WeeklyCubit() : super(WeeklyState());

  void onGetDataForChildId(int childId) {
    emit(state.copyWith(status: WeeklyStatus.loading));
  
    emit(state.copyWith(
      status: WeeklyStatus.success,
      summary: DashboardRepository.getDataForChildId(childId),
    ));
  }
}
