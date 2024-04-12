import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void onFocusChildChange(int childId) {
    emit(state.copyWith(status: DashboardStatus.success, focusChildId: childId));

  }

  void onFocusViewChange(DashboardView view) {
    emit(state.copyWith(status: DashboardStatus.success, view: view));
  }
}
