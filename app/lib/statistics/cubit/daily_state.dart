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
  DateTime? earliestMonday;
  DateTime? latestMonday;
  bool isPastData;
  DailyState({
    this.status = DailyStatus.initial,
    this.dailyStats = const [],
    required this.targetMinutes,
    this.earliestMonday,
    this.latestMonday,
    required this.isPastData,
  });

  DailyState copyWith({
    DailyStatus? status,
    List<SingleWeekHourlyStatsModel>? dailyStats,
    int? targetMinutes,
    DateTime? earliestMonday,
    DateTime? latestMonday,
    bool? isPastData,
  }) {
    return DailyState(
      status: status ?? this.status,
      dailyStats: dailyStats ?? this.dailyStats,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      earliestMonday: earliestMonday ?? this.earliestMonday,
      latestMonday: latestMonday ?? this.latestMonday,
      isPastData: isPastData ?? this.isPastData,
    );
  }

  @override
  List<Object?> get props => [status, dailyStats];
}
