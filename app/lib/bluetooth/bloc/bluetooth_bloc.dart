import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';
import '../../data/child_model.dart';
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

  FutureOr<void> _onBluetoothScanStartPressed(BluetoothScanStartPressed event, Emitter<BluetoothState> emit) {
  }

  FutureOr<void> _onBluetoothScanStopPressed(BluetoothScanStopPressed event, Emitter<BluetoothState> emit) {
  }

  FutureOr<void> _onBluetoothPairPressed(BluetoothPairPressed event, Emitter<BluetoothState> emit) {
  }

  FutureOr<void> _onBluetoothUnpairPressed(BluetoothUnpairPressed event, Emitter<BluetoothState> emit) {
  }

  FutureOr<void> _onBluetoothConnectPressed(BluetoothConnectPressed event, Emitter<BluetoothState> emit) {
  }

  FutureOr<void> _onBluetoothSyncPressed(BluetoothSyncPressed event, Emitter<BluetoothState> emit) {
  }
}
