part of 'monthly_cubit.dart';

enum MonthlyStatus {
  initial,
  loading,
  success,
  failure,
}

extension MonthlyStatusX on MonthlyStatus {
  bool get isInitial => this == MonthlyStatus.initial;
  bool get isLoading => this == MonthlyStatus.loading;
  bool get isSuccess => this == MonthlyStatus.success;
  bool get isFailure => this == MonthlyStatus.failure;
}

class MonthlyState extends Equatable {
  final MonthlyStatus status;
  final int focusYear;
  final int focusMonth;
  SingleYearDailyStatsModel? monthlyStats;

  MonthlyState({
    this.status = MonthlyStatus.initial,
    required this.focusYear,
    required this.focusMonth,
    this.monthlyStats,
  });

  MonthlyState copyWith({
    MonthlyStatus? status,
    int? focusYear,
    int? focusMonth,
    SingleYearDailyStatsModel? monthlyStats,
  }) {
    return MonthlyState(
      status: status ?? this.status,
      focusYear: focusYear ?? this.focusYear,
      focusMonth: focusMonth ?? this.focusMonth,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }

  @override
  List<Object?> get props => [status, focusYear, focusMonth, monthlyStats];
}
