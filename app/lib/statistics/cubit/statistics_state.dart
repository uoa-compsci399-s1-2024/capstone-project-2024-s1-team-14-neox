part of 'statistics_cubit.dart';

enum StatisticsStatus {
  initial,
  loading,
  success,
  failure,
}

enum StatisticsView {
  daily,
  weekly, 
  monthly,
}
extension StatisticsStatusX on StatisticsStatus {
  bool get isLoading => this == StatisticsStatus.loading;
  bool get isInitial => this == StatisticsStatus.initial;
  bool get isSuccess => this == StatisticsStatus.success;
  bool get isFailure => this == StatisticsStatus.failure;
}

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final int focusChildId;
  final StatisticsView view;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.focusChildId = -1,
    this.view = StatisticsView.daily,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    int? focusChildId,
    StatisticsView? view,
  }) {
    return StatisticsState(
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
