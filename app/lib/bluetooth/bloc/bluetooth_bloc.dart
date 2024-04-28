import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {

  BluetoothBloc() : super(const BluetoothIdleState(scanResults: [])) {
    on<BluetoothScanStarted>(_wrapCatch(_onBluetoothScanStart));
    on<BluetoothConnectPressed>(_wrapCatch(_onBluetoothConnectPressed));
    on<BluetoothAuthCodeEntered>(_wrapCatch(_onBluetoothAuthCodeEntered));
  }

  Future<void> Function(Event, Emitter<BluetoothState>)
  _wrapCatch<Event>(Future<void> Function(Event, Emitter<BluetoothState>) function) {
    return (Event event, Emitter<BluetoothState> emit) async {
      try {
        await function(event, emit);
      } catch (e) {
        emit(BluetoothErrorState(
          scanResults: state.scanResults,
          errorMessage: "An error occurred: $e"),
        );
      }
    };
  }

  Future<void> _onBluetoothScanStart(BluetoothScanStarted event, Emitter<BluetoothState> emit) async {
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    }

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    emit(const BluetoothScanLoadingState(scanResults: []));

    var scan = FlutterBluePlus.scanResults.listen((results) {
      emit(BluetoothScanLoadingState(scanResults: results));
    });

    await FlutterBluePlus.startScan(
      withServices: [Guid("ba5c0000-243e-4f78-ac25-69688a1669b4")],
      timeout: const Duration(seconds: 15),
    );
    await Future.delayed(const Duration(seconds: 15));

    await scan.cancel();
    await FlutterBluePlus.stopScan();
    emit(BluetoothIdleState(scanResults: state.scanResults));
  }

  Future<void> _onBluetoothConnectPressed(
      BluetoothConnectPressed event, Emitter<BluetoothState> emit) async {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    emit(BluetoothAuthCodeInputState(
      scanResults: state.scanResults,
      deviceRemoteId: event.deviceRemoteId
    ));
  }

  Future<void> _onBluetoothAuthCodeEntered(
      BluetoothAuthCodeEntered event, Emitter<BluetoothState> emit) async {
    emit(BluetoothConnectSuccessState(
      scanResults: state.scanResults,
      newDeviceRemoteId: event.deviceRemoteId,
      newAuthorisationCode: event.authorisationCode
    ));
  }
}
