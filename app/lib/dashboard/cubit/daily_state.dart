part of 'daily_cubit.dart';

enum DailyStatus {
  initial,
  loading,
  success,
  failure,
}

extension DailyStatusX on DailyStatus {
  bool get isInitial => this == DailyStatus.initial;
  bool get isLoading => this == DailyStatus.loading;
  bool get isSuccess => this == DailyStatus.success;
  bool get isFailure => this == DailyStatus.failure;
}

class DailyState extends Equatable {
  final DailyStatus status;
  final Map<DateTime, int>? summary;

  const DailyState({
    this.status = DailyStatus.initial,
    this.summary,
  });

  DailyState copyWith({
    DailyStatus? status,
    Map<DateTime, int>? summary,
  }) {
    return DailyState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [status, summary];
}
