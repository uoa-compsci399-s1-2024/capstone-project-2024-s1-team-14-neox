part of 'dashboard_cubit.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  failure,
}

enum DashboardView {
  daily,
  weekly, 
  monthly,
}
extension DashboardStatusX on DashboardStatus {
  bool get isLoading => this == DashboardStatus.loading;
  bool get isInitial => this == DashboardStatus.initial;
  bool get isSuccess => this == DashboardStatus.success;
  bool get isFailure => this == DashboardStatus.failure;
}

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int focusChildId;
  // TODO: only need list of int to represent how much time was spend outdoors
  // Might need three lists to represent day, week, month
  final DashboardView view;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.focusChildId = -1,
    this.view = DashboardView.daily,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    int? focusChildId,
    DashboardView? view,
  }) {
    return DashboardState(
      status: status ?? this.status,
      focusChildId: focusChildId ?? this.focusChildId,
      view: view ?? this.view,
    );
  }

  @override
  List<Object?> get props => [
        status,
        focusChildId,
        view,
      ];
}
