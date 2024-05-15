import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(const StatisticsState());

  void onFocusChildChange(int childId) {
    emit(state.copyWith(status: StatisticsStatus.success, focusChildId: childId));

  }

  void onFocusViewChange(StatisticsView view) {
    emit(state.copyWith(status: StatisticsStatus.success, view: view));
  }
}
