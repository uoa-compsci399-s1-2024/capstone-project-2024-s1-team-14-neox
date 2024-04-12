part of 'daily_cubit.dart';

sealed class DailyState extends Equatable {
  const DailyState();

  @override
  List<Object> get props => [];
}

final class DailyInitial extends DailyState {}
