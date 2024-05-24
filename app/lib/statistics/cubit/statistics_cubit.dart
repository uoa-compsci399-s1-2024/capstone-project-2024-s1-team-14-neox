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
    print("inside on focus child change start");
    emit(StatisticsInitial(detailedView: state.detailedView));
    _statisticsRepository.deleteCache();
    await _statisticsRepository.updateFocusChildId(childId);
    if (state.detailedView) {
      print("focus child detailed view");
      emit(StatisticsDetailed(focusChildId: childId, detailedView: true));
    } else {
      print("focus child overview");
      emit(StatisticsOverview(focusChildId: childId, detailedView: false));
    }
  }

  void onFocusViewToggle() {
    print("in focus view $state");
    print("testing onFocusViewToggle");
    if (state is StatisticsInitial) {
      emit(StatisticsInitial(detailedView: !state.detailedView));
      return;
    }
    if (state.detailedView) {
      print("stats cubit currently detailed");
      emit(StatisticsOverview(
          focusChildId: (state as StatisticsDetailed).focusChildId,
          detailedView: false));
    } else {
      emit(StatisticsOverview(
          focusChildId: (state as StatisticsOverview).focusChildId,
          detailedView: true));
    }
  }
}
