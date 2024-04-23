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
      withKeywords: ["Neox"],
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

    emit(BluetoothConnectLoadingState(scanResults: state.scanResults));
    BluetoothDevice device = BluetoothDevice.fromId(event.deviceRemoteId);

    await device.connect(mtu: 23);
    emit(BluetoothConnectSuccessState(
      scanResults: state.scanResults,
      newDeviceRemoteId: device.remoteId.str,
    ));

    // Don't hold up other devices from connecting.
    // Get our deviceRemoteId and finish.
    await device.disconnect();
  }
}
