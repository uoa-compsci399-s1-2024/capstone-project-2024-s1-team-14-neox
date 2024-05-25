part of 'statistics_cubit.dart';

abstract class StatisticsState {
  final int? focusChildId;
  const StatisticsState({this.focusChildId});
}

class DetailedStatisticsState extends StatisticsState {
  const DetailedStatisticsState({super.focusChildId});
}

class OverviewStatisticsState extends StatisticsState {
  const OverviewStatisticsState({super.focusChildId});
}
