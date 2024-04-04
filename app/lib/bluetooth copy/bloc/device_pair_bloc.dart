import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../data/child_repository.dart';

part 'device_pair_event.dart';
part 'device_pair_state.dart';

class DevicePairBloc extends Bloc<DevicePairEvent, DevicePairState> {
  final ChildRepository _childRepository;

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  // Constructor
  DevicePairBloc(this._childRepository) : super(
            // TODO: Conditional check to repository to check if child has paired device
            // Check if Device model is null
            // _childRepository.childHasPairedDevice(childID: childID)
            // ? DevicePairState.paired
            DevicePairState()) {
    // Notes: if using copyWith then emit using state.copyWith(status: DevicePairStatus. ....)
    // https://github.com/felangel/bloc/blob/master/examples/flutter_weather/lib/weather/cubit/weather_cubit.dart

    // If NOT using copyWith, then need to initialise each state using const DevicePairState.loading() : this._()
    // https://github.com/felangel/bloc/blob/master/examples/flutter_complex_list/lib/complex_list/cubit/complex_list_state.dart

    // Sets subscriptions
    // Won't use stream subscription due to forEach
    // late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
    // late StreamSubscription<bool> _isScanningSubscription;

    // Boilerplate code to call corresponding methods relating to the event
    on<DeviceScanStartPressed>(_onDeviceScanStartPressed);
    on<DeviceScanStopPressed>(_onDeviceScanStopPressed);
    on<DevicePairPressed>(_onDevicePairPressed);
    on<DeviceUnpairPressed>(_onDeviceUnpairPressed);
    on<DeviceConnectPressed>(_onDeviceConnectPressed);
    on<DeviceSyncPressed>(_onDeviceSyncPressed);
  }

//   Future<void> scanBluetooth() async {
//  List<BluetoothDevice> _systemDevices = [];
//   List<ScanResult> _scanResults = [];
//   bool _isScanning = false;
//   late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
//   late StreamSubscription<bool> _isScanningSubscription;

//     if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
//       if (Platform.isAndroid) {
//         await FlutterBluePlus.turnOn();
//       }
//     }
//     _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
//       print(results);
//       _scanResults = results;
//     });

//     FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription);

//     await FlutterBluePlus.startScan(
//   // withServices:[Guid("180D")],
//   // withNames:["Bluno"],
//   timeout: const Duration(seconds:15));
//   }

  // Since we are using Equatable, use state.copyWith NOT DevicePairState(....)
  // https://github.com/felangel/bloc/blob/dc571dab73ab0da70cc6689fd11d2b9221cc47a6/examples/flutter_todos/lib/stats/bloc/stats_bloc.dart#L23
  Future<void> _onDeviceScanStartPressed(
      DeviceScanStartPressed event, Emitter<DevicePairState> emit) async {

        if (FlutterBluePlus.isScanningNow) {
          FlutterBluePlus.stopScan();
        }
        
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    }
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      print(results);
      _scanResults = results;
      emit(state.copyWith(status: DevicePairStatus.scanLoading, scanResults: results));
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((result) {
      print("${DateTime.timestamp()} : ${result} ");
    });

    FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription);

    await FlutterBluePlus.startScan(
        // withServices:[Guid("180D")],
        // withNames:["Bluno"],
        timeout: const Duration(seconds: 15));

    await Future.delayed(const Duration(seconds: 15)).then((value) => {
          _isScanningSubscription.cancel(),
          emit(state.copyWith(status: DevicePairStatus.scanStopped)),
        });

    // await scanBluetooth();
    // emit(state.copyWith(status: DevicePairStatus.scanLoading));

    /*
        
    print("1");

        await FlutterBluePlus.stopScan();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!FlutterBluePlus.isScanningNow) {
        return;
      }
      _scanResults = results;
      print("DEVICE PAIR BLOC $results");
    });
    print("2");

    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        emit(state.copyWith(
            status: DevicePairStatus.error,
            errorMessage: "Please turn Bluetooth on"));
      }
    }
    print("3");
    emit(state.copyWith(status: DevicePairStatus.scanLoading));
    print("4");

    // _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
    //   print("Scan screen subscription: $results");
    //   _scanResults = results;
    //   emit(state.copyWith(scanResults: _scanResults));
    // }, onError: (e) {
    //   emit(
    //     state.copyWith(
    //       status: DevicePairStatus.error,
    //       errorMessage: e.toString(),
    //     ),
    //   );
    // });

    await FlutterBluePlus.startScan(
        // withServices: [Guid("180D")],
        // withNames: ["Bluno"],
        timeout: const Duration(seconds: 15));

    // await emit.onEach(scanResultStream, onData: (result) {
    //   print("ScNANNING DEVICE PAIR BLOC");
    //   print(result);
    // });
    print("5");

    //  await emit.forEach(
    //   scanResultStream,
    //   onData: (results) =>
    //      state.copyWith(scanResults: results),
    // );
    print("6");

    await Future.delayed(const Duration(seconds: 15));

// wait for scanning to stop
    print("7");
    await FlutterBluePlus.stopScan();

    print("DEVICE PAIR BLOC: STOPEED SCAN");
    print("8");
    await _scanResultsSubscription.cancel();
    print("9");
    emit(state.copyWith(status: DevicePairStatus.scanStopped));

    */
  }

  FutureOr<void> _onDeviceScanStopPressed(
      DeviceScanStopPressed event, Emitter<DevicePairState> emit) {
    FlutterBluePlus.stopScan();
    emit(state.copyWith(status: DevicePairStatus.scanStopped));
  }

  FutureOr<void> _onDevicePairPressed(
      DevicePairPressed event, Emitter<DevicePairState> emit) {}

  FutureOr<void> _onDeviceUnpairPressed(
      DeviceUnpairPressed event, Emitter<DevicePairState> emit) {}

  FutureOr<void> _onDeviceConnectPressed(
      DeviceConnectPressed event, Emitter<DevicePairState> emit) {}

  FutureOr<void> _onDeviceSyncPressed(
      DeviceSyncPressed event, Emitter<DevicePairState> emit) {}
}
