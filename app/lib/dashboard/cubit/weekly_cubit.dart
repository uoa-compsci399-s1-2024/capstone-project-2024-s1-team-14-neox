import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'weekly_state.dart';

class WeeklyCubit extends Cubit<WeeklyState> {
  WeeklyCubit() : super(WeeklyInitial());
}
