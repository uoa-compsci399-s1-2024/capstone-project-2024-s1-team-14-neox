import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/domain/child_device_repository.dart';
import '../domain/sensor_data_model.dart';

part 'analysis_result_event.dart';
part 'analysis_result_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  AnalysisBloc() : super(AnalysisState()) {
    on<AnalysisChangeChildEvent>(_onAnalysisChangeChildEvent);
    on<AnalysisLoadDataEvent>(_onAnalysisLoadDataEvent);
  }

  Future<void> _onAnalysisChangeChildEvent(
      AnalysisChangeChildEvent event, Emitter<AnalysisState> emit) async {
    emit(state.copyWith(status: AnalysisStatus.loading));
    // List<SensorDataModel> data =
    //     await ChildDeviceRepository.fetchArduinoSamplesByChildId(event.childId);

    List<SensorDataModel>? data =
        ChildDeviceRepository.fetchArduinoSamplesByChildId(event.childId);
    if (data != null) {
      emit(state.copyWith(
        status: AnalysisStatus.success,
        data: data,
      ));
    } else {
      emit(state.copyWith(
        status: AnalysisStatus.failure,
      ));
    }
  }

  Future<void> _onAnalysisLoadDataEvent(
      AnalysisLoadDataEvent event, Emitter<AnalysisState> emit) async {
    emit(state.copyWith(status: AnalysisStatus.loading));
    // List<SensorDataModel> data =
    // await ChildDeviceRepository.fetchArduinoSamplesByChildId(event.childId);
    List<SensorDataModel>? data =
        ChildDeviceRepository.fetchArduinoSamplesByChildId(event.childId);
    if (data != null) {
      emit(state.copyWith(
        status: AnalysisStatus.success,
        data: data,
      ));
    } else {
      emit(state.copyWith(
        status: AnalysisStatus.failure,
      ));
    }
  }
}
