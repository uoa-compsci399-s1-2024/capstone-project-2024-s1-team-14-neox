import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/dB/database.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository _statisticsRepository;
  StatisticsCubit(this._statisticsRepository)
      : super(StatisticsInitial(detailedView: true));

  void onInitialise() async {
    int? childId = await _statisticsRepository.getFocusChildId();
    print("initialising statistics cubit");
    if (childId != null) {
      emit(StatisticsDetailed(focusChildId: childId, detailedView: true));
    }
  }

  void onFocusChildChange(int childId) async {
    _statisticsRepository.deleteCache();
    await _statisticsRepository.updateFocusChildId(childId);
    if (state.detailedView) {
      emit(StatisticsDetailed(focusChildId: childId, detailedView: true));
    }
    emit(StatisticsOverview(focusChildId: childId, detailedView: false));
  }

  void onFocusViewToggle() {
    print("in focus view $state");
    if (state is StatisticsDetailed) {
      emit(StatisticsOverview(
          focusChildId: (state as StatisticsDetailed).focusChildId,
          detailedView: false));
    } else if (state is StatisticsOverview) {
      emit(StatisticsOverview(
          focusChildId: (state as StatisticsOverview).focusChildId,
          detailedView: true));
    }
    emit(StatisticsInitial(detailedView: !state.detailedView));
  }
}
