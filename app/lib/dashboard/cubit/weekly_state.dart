part of 'weekly_cubit.dart';

enum WeeklyStatus {
  initial,
  loading,
  success,
  failure,
}

extension WeeklyStatusX on WeeklyStatus {
  bool get isInitial => this == WeeklyStatus.initial;
  bool get isLoading => this == WeeklyStatus.loading;
  bool get isSuccess => this == WeeklyStatus.success;
  bool get isFailure => this == WeeklyStatus.failure;
}

class WeeklyState extends Equatable {
  final WeeklyStatus status;
  final Map<DateTime, int>? summary;

  const WeeklyState({
    this.status = WeeklyStatus.initial,
    this.summary,
  });

  WeeklyState copyWith({
    WeeklyStatus? status,
    Map<DateTime, int>? summary,
  }) {
    return WeeklyState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [status, summary];
}
