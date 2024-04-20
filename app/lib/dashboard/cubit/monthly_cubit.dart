import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'monthly_state.dart';

class MonthlyCubit extends Cubit<MonthlyState> {
  MonthlyCubit() : super(MonthlyInitial());
}
