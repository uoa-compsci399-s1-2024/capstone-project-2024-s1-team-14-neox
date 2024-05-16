import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:equatable/equatable.dart';

part 'monthly_state.dart';

class MonthlyCubit extends Cubit<MonthlyState> {
  StatisticsRepository _statisticsRepository;
  MonthlyCubit(this._statisticsRepository) : super(MonthlyInitial());
}
