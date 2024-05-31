import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository _statisticsRepository;

  StatisticsCubit(this._statisticsRepository)
      : super(DetailedStatisticsState(focusChildId: _statisticsRepository.getFocusChildId()));

  void onFocusChildChange(int childId) async {
    _statisticsRepository.deleteCache();
    await _statisticsRepository.updateFocusChildId(childId);
    if (isClosed) {
      return;
    }

    if (state is DetailedStatisticsState) {
      emit(DetailedStatisticsState(focusChildId: childId));
    } else {
      emit(OverviewStatisticsState(focusChildId: childId));
    }
  }

  void onFocusViewToggle() {
    if (state is DetailedStatisticsState) {
      emit(OverviewStatisticsState(focusChildId: state.focusChildId));
    } else {
      emit(DetailedStatisticsState(focusChildId: state.focusChildId));
    }
  }
}
