part of 'weekly_cubit.dart';

sealed class WeeklyState extends Equatable {
  const WeeklyState();

  @override
  List<Object> get props => [];
}

final class WeeklyInitial extends WeeklyState {}
