import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];

  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  /*
   * TODO: Hard coded Arduino uuid: need to replace with values in the arduino repository
  */

  String uuidSerivce = "ba5c0000-243e-4f78-ac25-69688a1669b4";
  List<String> uuidSamples = [
    "42b25f8f-0000-43de-92b8-47891c706106",
    "5c5ef115-0001-431d-8c23-52ff6ad1e467",
    "1fc0372f-0002-43f3-8cfc-1a5611b88062",
    "ff3d9730-0003-4aac-84e2-0861c1d000a6",
    "6eea8c3b-0004-4ec0-a842-6ed292e598dd",
  ];
  String uuidAcknowledgement = "f06c06bb-0005-4f4c-b6b4-a146eff5ab15";

  BluetoothBloc() : super(BluetoothState()) {
    on<BluetoothScanStartPressed>(_onBluetoothScanStartPressed);
    on<BluetoothScanStopPressed>(_onBluetoothScanStopPressed);
    on<BluetoothConnectPressed>(_onBluetoothConnectPressed);
    on<BluetoothDisconnectPressed>(_onBluetoothDisconnectPressed);
    on<BluetoothSyncPressed>(_onBluetoothSyncPressed);
  }

  Future<void> _onBluetoothScanStartPressed(
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

  Future<void> _onBluetoothConnectPressed(
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

  Future<void> _onBluetoothSyncPressed(
      BluetoothSyncPressed event, Emitter<BluetoothState> emit) async {
    if (event.deviceRemoteId == "") {
      emit(
        state.copyWith(
            status: BluetoothStatus.error, message: "No device paired"),
      );
      return;
    }

    // Connect to device if not connected already
    BluetoothDevice device = BluetoothDevice.fromId(event.deviceRemoteId);
    if (device.isDisconnected) {
      await device.connect(mtu: 23);
      print(
          "${device.disconnectReason?.code} $device.disconnectReason?.description}");
    }

    // Find characteristics
    List<BluetoothCharacteristic?> sampleCharacteristics = [];
    BluetoothCharacteristic? acknowledgementCharacteristic;
    sampleCharacteristics.length = uuidSamples.length;
    for (BluetoothService service in await device.discoverServices()) {
      if (service.uuid.toString().toLowerCase() != uuidSerivce) {
        continue;
      }

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        String characteristicUuid =
            characteristic.characteristicUuid.toString().toLowerCase();

        if (characteristicUuid == uuidAcknowledgement) {
          acknowledgementCharacteristic = characteristic;
          continue;
        }

        for (int i = 0; i < uuidSamples.length; i++) {
          if (characteristicUuid == uuidSamples[i]) {
            sampleCharacteristics[i] = characteristic;
            break;
          }
        }
      }
      break;
    }

    // Check if all characteristics are found
    if (sampleCharacteristics
            .any((char) => char == null || !char.properties.read) ||
        acknowledgementCharacteristic == null ||
        !acknowledgementCharacteristic.properties.write) {
      emit(
        state.copyWith(
            status: BluetoothStatus.error,
            message: "Service missing characteristics"),
      );
      return;
    }

    // Read sensor data
    int sampleCharacteristicIndex = 0;
    List<List<int>> values = [];
    await acknowledgementCharacteristic.write([0x01]);
    while (true) {
      BluetoothCharacteristic sampleCharacteristic =
          sampleCharacteristics[sampleCharacteristicIndex]!;
      List<int> value = await sampleCharacteristic.read();

      sampleCharacteristicIndex++;
      if (sampleCharacteristicIndex >= sampleCharacteristics.length) {
        sampleCharacteristicIndex = 0;
        await acknowledgementCharacteristic.write([0x01]);
      }

      if (value.every((byte) => byte == 0)) {
        break;
      }

      values.add(value);
    }

    // Send samples to repository
    for (List<int> value in values) {
      await ChildDeviceRepository.parseAndSaveSamples(event.childName, value, event.childId);
    }
  }

  Future<void> _onBluetoothDisconnectPressed(
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
