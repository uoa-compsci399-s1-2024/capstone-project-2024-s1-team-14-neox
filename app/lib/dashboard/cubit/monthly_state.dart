part of 'monthly_cubit.dart';

sealed class MonthlyState extends Equatable {
  const MonthlyState();

  @override
  List<Object> get props => [];
}

final class MonthlyInitial extends MonthlyState {}
