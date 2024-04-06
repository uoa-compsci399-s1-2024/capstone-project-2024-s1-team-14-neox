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
  final String? _deviceRemoteId;

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  BluetoothBloc(this._deviceRemoteId) : super(BluetoothState()) {
    on<BluetoothScanStartPressed>(_onBluetoothScanStartPressed);
    on<BluetoothScanStopPressed>(_onBluetoothScanStopPressed);
    on<BluetoothConnectPressed>(_onBluetoothConnectPressed);
    on<BluetoothDisconnectPressed>(_onBluetoothDisconnectPressed);
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

    _systemDevices = await FlutterBluePlus.systemDevices;
    emit(
      state.copyWith(
        status: BluetoothStatus.scanLoading,
        systemDevices: _systemDevices,
      ),
    );

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      emit(state.copyWith(scanResults: results));
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((result) {
      print("${DateTime.timestamp()} : ${result} ");
    });

    await FlutterBluePlus.startScan(
      // withServices:[Guid("180D")],
      // withNames:["Bluno"],
      timeout: const Duration(seconds: 15),
    );
    await Future.delayed(const Duration(seconds: 15))
        .then((value) => {
              _isScanningSubscription.cancel(),
              _scanResultsSubscription.cancel(),
            })
        .whenComplete(
          () => emit(
            state.copyWith(status: BluetoothStatus.scanStopped),
          ),
        );
  }

  FutureOr<void> _onBluetoothScanStopPressed(
      BluetoothScanStopPressed event, Emitter<BluetoothState> emit) {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
    emit(state.copyWith(status: BluetoothStatus.scanStopped));
  }

  Future<FutureOr<void>> _onBluetoothConnectPressed(
      BluetoothConnectPressed event, Emitter<BluetoothState> emit) async {
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    emit(state.copyWith(status: BluetoothStatus.connectLoading));
    BluetoothDevice device = BluetoothDevice.fromId(event.deviceRemoteId);

    if (device.isDisconnected) {
      await device.connect(mtu: 23).then((value) => {
            if (device.isConnected)
              {
                print("Connected: ${event.deviceRemoteId}"),
                emit(state.copyWith(
                    status: BluetoothStatus.connectSuccess,
                    newDeviceRemoteId: device.remoteId.str,
                    message: "Successfully paired device")),
              }
            else
              {
                emit(
                  state.copyWith(
                      status: BluetoothStatus.error,
                      message: "Failed to pair device"),
                ),
              }
          });
    }

    // var subscription = device.connectionState
    //     .listen((BluetoothConnectionState connectionState) async {
    //   print("Device conenction state: $connectionState");
    //   if (connectionState == BluetoothConnectionState.disconnected) {
    //     await device.connect(mtu: 23);
    //     print(
    //         "${device.disconnectReason?.code} ${device.disconnectReason?.description}");
    //   }
    // });

    // subscription.cancel();
  }

  Future<FutureOr<void>> _onBluetoothSyncPressed(
      BluetoothSyncPressed event, Emitter<BluetoothState> emit) async {
    // // Test to check connection
    // for (ScanResult result in _scanResults) {
    //   BluetoothDevice device = result.device;
    //   print(device.remoteId.toString());
    //   if (device.remoteId.toString() == "38:8A:06:8A:D4:37") {
    //     await device.connect(mtu: 512);
    //     print("Checking is connected: ${device.isConnected}");
    //   }
    // }
    if (_deviceRemoteId == null) {
      emit(
        state.copyWith(
            status: BluetoothStatus.error, message: "No device paired"),
      );
    } else {
      BluetoothDevice device = BluetoothDevice.fromId(_deviceRemoteId);
      if (device.isDisconnected) {
        await device.connect(mtu: 23);
        print(
            "${device.disconnectReason?.code} $device.disconnectReason?.description}");
      }

      //TODO @Kevin
      // Resources
      // https://github.com/boskokg/flutter_blue_plus/issues/274
      // https://pub.dev/packages/flutter_blue_plus#subscribe-to-a-characteristic
    }

    // var subscription = event.device.connectionState
    //     .listen((BluetoothConnectionState connectionState) async {
    //   //TODO: scan again before syncing
    //   //if disconnected discover services again
    //   // Try connecting with device remote id stored in the child repository
    //   if (connectionState == BluetoothConnectionState.disconnected) {
    //     await event.device.connect(mtu: 23);
    //     print(
    //         "${event.device.disconnectReason?.code} ${event.device.disconnectReason?.description}");
    //   }
    // });

    // subscription.cancel();
  }

  Future<FutureOr<void>> _onBluetoothDisconnectPressed(
      BluetoothDisconnectPressed event, Emitter<BluetoothState> emit) async {
    print("disconnect pressed");
    emit(state.copyWith(status: BluetoothStatus.disconnectLoading));
    BluetoothDevice device = BluetoothDevice.fromId(event.deviceRemoteId);
    await device.disconnect();

    if (!device.isConnected) {
      print("Disconnected: ${event.deviceRemoteId}");
      emit(state.copyWith(
          status: BluetoothStatus.disconnectSuccess,
          message: "Successfully disconnected device"));
    } else {
      emit(
        state.copyWith(
            status: BluetoothStatus.error,
            message: "Failed to disconnect device"),
      );
    }
  }
}
