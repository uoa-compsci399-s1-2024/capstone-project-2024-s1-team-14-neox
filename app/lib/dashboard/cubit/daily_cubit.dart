import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'daily_state.dart';

class DailyCubit extends Cubit<DailyState> {
  DailyCubit() : super(DailyInitial());
}
