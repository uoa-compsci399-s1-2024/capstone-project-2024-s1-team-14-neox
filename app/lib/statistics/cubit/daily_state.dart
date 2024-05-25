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
  final List<SingleWeekHourlyStatsModel> dailyStats;
  int? targetMinutes;
  DailyState({
    this.status = DailyStatus.initial,
    this.dailyStats = const [],
    required this.targetMinutes,
  });

  DailyState copyWith({
    DailyStatus? status,
    List<SingleWeekHourlyStatsModel>? dailyStats,
    int? targetMinutes,
  }) {
    return DailyState(
      status: status ?? this.status,
      dailyStats: dailyStats ?? this.dailyStats,
      targetMinutes: targetMinutes ?? this.targetMinutes,
    );
  }

  @override
  List<Object?> get props => [status, dailyStats];
}
