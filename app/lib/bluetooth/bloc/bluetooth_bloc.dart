import 'dart:math';

import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_repository.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
  String uuidAuthChallengeFromPeripheral = "9ab7d3df-a7b4-4858-8060-84a9adcf1420";
  String uuidAuthResponseFromCentral = "a90aa9a2-b186-4717-bc8d-f169eead75da";
  String uuidAuthChallengeFromCentral = "c03b7267-dcfa-4525-8521-1bc31c08c312";
  String uuidAuthResponseFromPeripheral = "750d5d43-96c4-4f5c-8ce1-fdb44a150336";
  String uuidCentralAuthenticated = "776edbca-a020-4d86-a5e8-25eb87e82554";

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
      // withNames:["Neox"], //TODO uncomment this to search for only Neox Sens
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

  static List<int> _solveAuthChallenge(List<int> challenge, List<int> key) {
    if (challenge.length != 32) {
      // If the device sends us an invalid challenge,
      // we might as well send them back an invalid response :P
      return [];
    }

    List<int> combined = [];
    for (int i = 0; i < challenge.length; i++) {
      combined.add(challenge[i] ^ key[i]);
    }

    return sha256.convert(combined).bytes;
  }
  
  Future<void> _onBluetoothSyncPressed(
    BluetoothSyncPressed event,
    Emitter<BluetoothState> emit) async
  {
    try {
      await _onBluetoothSyncPressedNoCatch(event, emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          message: "An error occurred: $e"
        ),
      );
    }
  }

  Future<void> _onBluetoothSyncPressedNoCatch(
    BluetoothSyncPressed event,
    Emitter<BluetoothState> emit) async
  {
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
    }

    // Find characteristics
    List<BluetoothCharacteristic?> sampleData = [];
    BluetoothCharacteristic? acknowledgement;
    BluetoothCharacteristic? authChallengeFromPeripheral;
    BluetoothCharacteristic? authResponseFromCentral;
    BluetoothCharacteristic? authChallengeFromCentral;
    BluetoothCharacteristic? authResponseFromPeripheral;
    BluetoothCharacteristic? centralAuthenticated;
    sampleData.length = uuidSamples.length;
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() != uuidSerivce) {
        continue;
      }

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        String characteristicUuid =
            characteristic.characteristicUuid.toString().toLowerCase();

        if (characteristicUuid == uuidAcknowledgement) {
          acknowledgement = characteristic;
        } else if (characteristicUuid == uuidAuthChallengeFromPeripheral) {
          authChallengeFromPeripheral = characteristic;
        } else if (characteristicUuid == uuidAuthResponseFromCentral) {
          authResponseFromCentral = characteristic;
        } else if (characteristicUuid == uuidAuthChallengeFromCentral) {
          authChallengeFromCentral = characteristic;
        } else if (characteristicUuid == uuidAuthResponseFromPeripheral) {
          authResponseFromPeripheral = characteristic;
        } else if (characteristicUuid == uuidCentralAuthenticated) {
          centralAuthenticated = characteristic;
        } else {
          for (int i = 0; i < uuidSamples.length; i++) {
            if (characteristicUuid == uuidSamples[i]) {
              sampleData[i] = characteristic;
              break;
            }
          }
        }
        
      }
      break;
    }

    // Check if all characteristics are found
    List<BluetoothCharacteristic?> writeCharacteristics = [
      acknowledgement,
      authResponseFromCentral,
      authChallengeFromCentral,
      authResponseFromPeripheral,
    ];
    List<BluetoothCharacteristic?> readCharacteristics = [
      ...sampleData,
      authChallengeFromPeripheral,
      authResponseFromPeripheral,
      centralAuthenticated,
    ];
    if (readCharacteristics.any((char) => char == null || !char.properties.read)
      || writeCharacteristics.any((char) => char == null || !char.properties.write)) {
      emit(
        state.copyWith(
            status: BluetoothStatus.error,
            message: "Service missing characteristics"),
      );
      return;
    }

    // Authenticate us
    String authorisationCode = event.authorisationCode;
    if (authorisationCode.length != 10 || authorisationCode.codeUnits.any((c) => c >= 128)) {
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          message: "Invalid authorisation code"
        ),
      );
      return;
    }
    List<int> key = [...event.authorisationCode.codeUnits];
    while (key.length < 32) {
      key.add(0);
    }

    {
      List<int> challenge = await authChallengeFromPeripheral!.read();
      List<int> response = _solveAuthChallenge(challenge, key);
      await authResponseFromCentral!.write(response, allowLongWrite: true);
    }

    // Authenticate them
    {
      await authResponseFromPeripheral!.write(List.generate(32, (_) => 0), allowLongWrite: true);

      List<int> challenge = List.generate(32, (index) => Random.secure().nextInt(256));
      await authChallengeFromCentral!.write(challenge, allowLongWrite: true);

      List<int> response;
      int attempts = 0;
      while (true) {
        response = await authResponseFromPeripheral.read();
        if (response.any((byte) => byte != 0)) {
          break;
        }

        await Future.delayed(const Duration(seconds: 1));
        attempts++;
        if (attempts >= 10) {
          emit(
            state.copyWith(
              status: BluetoothStatus.error,
              message: "Device authentication timed out."
            ),
          );
          return;
        }
      };

      List<int> weAreAuthenticated = await centralAuthenticated!.read();
      if (weAreAuthenticated.isEmpty || weAreAuthenticated[0] == 0) {
        emit(
          state.copyWith(
            status: BluetoothStatus.error,
            message: "Failed to authenticate phone. Check the password and try again.",
          ),
        );
        return;
      }

      List<int> expectedResponse = _solveAuthChallenge(challenge, key);
      if (!listEquals(response, expectedResponse)) {
        emit(
          state.copyWith(
            status: BluetoothStatus.error,
            message: "Failed to authenticate device. Check you are connecting to the right device.",
          ),
        );
        return;
      }
    }

    // Read sensor data
    int sampleCharacteristicIndex = 0;
    List<List<int>> values = [];
    await acknowledgement!.write([1]);
    while (true) {
      BluetoothCharacteristic sampleCharacteristic = sampleData[sampleCharacteristicIndex]!;
      List<int> value = await sampleCharacteristic.read();

      sampleCharacteristicIndex++;
      if (sampleCharacteristicIndex >= sampleData.length) {
        sampleCharacteristicIndex = 0;
        await acknowledgement.write([1]);
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
