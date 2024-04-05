import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';
import '../../data/child_repository.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  // Refer to data repository
  final ChildRepository _childRepository;

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  BluetoothBloc(this._childRepository) : super(BluetoothState()) {
    on<BluetoothScanStartPressed>(_onBluetoothScanStartPressed);
    on<BluetoothScanStopPressed>(_onBluetoothScanStopPressed);
    on<BluetoothPairPressed>(_onBluetoothPairPressed);
    on<BluetoothUnpairPressed>(_onBluetoothUnpairPressed);
    on<BluetoothConnectPressed>(_onBluetoothConnectPressed);
    on<BluetoothSyncPressed>(_onBluetoothSyncPressed);
  }

  Future<FutureOr<void>> _onBluetoothScanStartPressed(
      BluetoothScanStartPressed event, Emitter<BluetoothState> emit) async {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    }

    // TODO: implement permission checking

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      print(results);
      _scanResults = results;
      emit(state.copyWith(
          status: BluetoothStatus.scanLoading, scanResults: results));
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((result) {
      print("${DateTime.timestamp()} : ${result} ");
    });

    await FlutterBluePlus.startScan(
      // withServices:[Guid("180D")],
      // withNames:["Bluno"],
      timeout: const Duration(seconds: 15),
    );
    await Future.delayed(const Duration(seconds: 15)).then((value) => {
          _isScanningSubscription.cancel(),
          _scanResultsSubscription.cancel,
          emit(state.copyWith(status: BluetoothStatus.scanStopped)),
        });
  }

  FutureOr<void> _onBluetoothScanStopPressed(
      BluetoothScanStopPressed event, Emitter<BluetoothState> emit) {
    FlutterBluePlus.stopScan();
    emit(state.copyWith(status: BluetoothStatus.scanStopped));
  }

  FutureOr<void> _onBluetoothPairPressed(
      BluetoothPairPressed event, Emitter<BluetoothState> emit) {}

  FutureOr<void> _onBluetoothUnpairPressed(
      BluetoothUnpairPressed event, Emitter<BluetoothState> emit) {}

  FutureOr<void> _onBluetoothConnectPressed(
      BluetoothConnectPressed event, Emitter<BluetoothState> emit) {}

  FutureOr<void> _onBluetoothSyncPressed(
      BluetoothSyncPressed event, Emitter<BluetoothState> emit) {}
}
