part of 'statistics_cubit.dart';

sealed class StatisticsState {
  final bool detailedView;

  StatisticsState({required this.detailedView});
}

class StatisticsInitial extends StatisticsState {
  StatisticsInitial({required super.detailedView});
}

class StatisticsDetailed extends StatisticsState {
  final int focusChildId;

  StatisticsDetailed({required this.focusChildId, required super.detailedView});
}

class StatisticsOverview extends StatisticsState {
  final int focusChildId;

  StatisticsOverview({required this.focusChildId, required super.detailedView});
}
