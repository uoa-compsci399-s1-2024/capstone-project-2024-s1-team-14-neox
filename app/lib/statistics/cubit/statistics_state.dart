part of 'statistics_cubit.dart';

abstract class StatisticsState extends Equatable {
  final bool detailedView;

  const StatisticsState({required this.detailedView});
  @override
  List<Object?> get props => [detailedView];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial({required super.detailedView});
}

class StatisticsDetailed extends StatisticsState {
  final int focusChildId;

  const StatisticsDetailed(
      {required this.focusChildId, required super.detailedView});
  @override
  List<Object?> get props => [detailedView, focusChildId];
}

class StatisticsOverview extends StatisticsState {
  final int focusChildId;

  const StatisticsOverview(
      {required this.focusChildId, required super.detailedView});
  @override
  List<Object?> get props => [detailedView, focusChildId];
}
