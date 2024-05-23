part of 'statistics_cubit.dart';

enum StatisticsStatus {
  initial,
  loading,
  success,
  failure,
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
  final bool detailedView;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.focusChildId = -1,
    this.detailedView = true,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    int? focusChildId,
    bool? detailedView,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      focusChildId: focusChildId ?? this.focusChildId,
      detailedView: detailedView ?? this.detailedView,
    );
  }

  @override
  List<Object?> get props => [
        status,
        focusChildId,
        detailedView,
      ];
}
