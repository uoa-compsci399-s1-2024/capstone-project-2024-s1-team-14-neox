import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'child_device_state.dart';

class ChildDeviceCubit extends Cubit<ChildDeviceState> {
  ChildDeviceRepository _repo;

  ChildDeviceCubit({
    required ChildDeviceRepository repo,
    required int childId,
    required String childName,
    required DateTime birthDate,
    required String gender,
    required String deviceRemoteId,
    required String authorisationCode,
  })  : _repo = repo,
        super(ChildDeviceIdleState(ChildDeviceState(
          childId: childId,
          childName: childName,
          birthDate: birthDate,
          gender: gender,
          deviceRemoteId: deviceRemoteId,
          authorisationCode: authorisationCode,
        )));

  void onChildDeviceConnectPressed(
      String deviceRemoteId, String authorisationCode) {
    emit(ChildDeviceConnectState(state, deviceRemoteId, authorisationCode));
  }

  void onChildDeviceDisconnectPressed() {
    emit(ChildDeviceDisconnectState(state));
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

  static String _formatRemoteDeviceId(List<int> bytes) {
    return bytes
        .map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))
        .join(':');
  }

  Future<BluetoothDevice?> _getBluetoothDevice(String deviceRemoteId) async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    await FlutterBluePlus.startScan(
      withServices: [Guid("ba5c0000-243e-4f78-ac25-69688a1669b4")],
      timeout: const Duration(seconds: 15),
    );

    try {
      await for (List<ScanResult> scanResults in FlutterBluePlus.scanResults
          .timeout(const Duration(seconds: 150))) {
        scanResults.retainWhere((r) =>
            deviceRemoteId ==
            _formatRemoteDeviceId(
                r.advertisementData.manufacturerData.values.firstOrNull ?? []));
        if (scanResults.isNotEmpty) {
          return scanResults.first.device;
        }
      }
    } on TimeoutException {
      // Do nothing
    } finally {
      await FlutterBluePlus.stopScan();
    }
    return null;
  }

  Future<void> onSyncPressed(
      {required String childName,
      required int childId,
      required String deviceRemoteId,
      required String authorisationCode}) async {
    BluetoothDevice? device;
    print("FIX ------------------------");
    print("FIX 99 sync pressed");
    // Turn on Bluetooth
    try {
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      }
      emit(ChildDeviceSyncingState(state, null));
      print("FIX Trying to get device line 110");
      device = await _getBluetoothDevice(deviceRemoteId);
      print("FIX Completed get device line 112");
    } catch (e) {
      emit(ChildDeviceErrorState(state, "Failed to turn on Bluetooth: $e"));
      print("FIX" + e.toString());
      return;
    }
    print("FIX line 118 checking if device is null");

    if (device == null) {
      emit(ChildDeviceErrorState(state, "Device not found nearby."));
      print("FIX device  not found");
      return;
    }

    print("FIX found device ${device.remoteId}");

    try {
      print("FIX 129 try connectimng ${device.remoteId}");
      await device.connect(mtu: 23);
      print("FIX 131 finish connectimng ${device.remoteId}");
    } catch (e) {
      emit(ChildDeviceErrorState(state, "Failed to connect to device: $e"));
      print("FIX errror connecting");
      await device.disconnect();
      return;
    }

    print("FIX 138 connected to device");

    const String uuidSerivce = "ba5c0000-243e-4f78-ac25-69688a1669b4";
    const List<String> uuidSamples = [
      "42b25f8f-0000-43de-92b8-47891c706106",
      "5c5ef115-0001-431d-8c23-52ff6ad1e467",
      "1fc0372f-0002-43f3-8cfc-1a5611b88062",
      "ff3d9730-0003-4aac-84e2-0861c1d000a6",
      "6eea8c3b-0004-4ec0-a842-6ed292e598dd",
    ];
    const String uuidAcknowledgement = "f06c06bb-0005-4f4c-b6b4-a146eff5ab15";
    const String uuidAuthChallengeFromPeripheral =
        "9ab7d3df-a7b4-4858-8060-84a9adcf1420";
    const String uuidAuthResponseFromCentral =
        "a90aa9a2-b186-4717-bc8d-f169eead75da";
    const String uuidAuthChallengeFromCentral =
        "c03b7267-dcfa-4525-8521-1bc31c08c312";
    const String uuidAuthResponseFromPeripheral =
        "750d5d43-96c4-4f5c-8ce1-fdb44a150336";
    const String uuidCentralAuthenticated =
        "776edbca-a020-4d86-a5e8-25eb87e82554";
    const String uuidProgress = "f06c06bb-0007-4f4c-b6b4-a146eff5ab15";

    try {
      print("FIX request connection priority");
      await device.requestConnectionPriority(
          connectionPriorityRequest: ConnectionPriority.high);
      print("FIX request connection priority success");

      // Find characteristics
      List<BluetoothCharacteristic?> sampleData = [];
      BluetoothCharacteristic? acknowledgement;
      BluetoothCharacteristic? authChallengeFromPeripheral;
      BluetoothCharacteristic? authResponseFromCentral;
      BluetoothCharacteristic? authChallengeFromCentral;
      BluetoothCharacteristic? authResponseFromPeripheral;
      BluetoothCharacteristic? centralAuthenticated;
      BluetoothCharacteristic? progress;
      sampleData.length = uuidSamples.length;
      print("FIX sicover services start");
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() != uuidSerivce) {
          continue;
        }

        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          String characteristicUuid =
              characteristic.characteristicUuid.toString().toLowerCase();
          print("FIX try match characterstic $characteristicUuid");
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
          } else if (characteristicUuid == uuidProgress) {
            progress = characteristic;
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
        progress,
      ];
      print("FIX 230 checking characteristics");
      if (readCharacteristics
              .any((char) => char == null || !char.properties.read) ||
          writeCharacteristics
              .any((char) => char == null || !char.properties.write)) {
        print("FIX 230 characteristic missing ");
        emit(ChildDeviceErrorState(state, "Service missing characteristics"));
        await device.disconnect();
        return;
      }

      // Authenticate us

      if (authorisationCode.length != 10 ||
          authorisationCode.codeUnits.any((c) => c >= 128)) {
        emit(
            ChildDeviceErrorState(state, "Invalid authorisation code format."));
        await device.disconnect();
        return;
      }
      List<int> key = [...authorisationCode.codeUnits];
      while (key.length < 32) {
        key.add(0);
      }

      print("FIX 252 setup key $key");
      {
        print("FIX 254 start auth CHALLENGE from periphe");
        List<int> challenge = await authChallengeFromPeripheral!.read();
        print("FIX ChalPeri 9ab $challenge");
        print("FIX 256 start solve auth challenge");
        List<int> response = _solveAuthChallenge(challenge, key);
        print("FIX 258 RespCent a90 $response");
        await authResponseFromCentral!.write(response, allowLongWrite: true);
        print("FIX 260 finished auth response from central");
      }
      print("FIX 262 authenticate them");
      // Authenticate them
      {
        print("FIX 262 start auth response from peripheral");
        await authResponseFromPeripheral!
            .write(List.generate(32, (_) => 0), allowLongWrite: true);
        print("FIX 265 RespPeri 750 write finsh auth response from peripheral");

        List<int> challenge =
            List.generate(32, (index) => Random.secure().nextInt(256));
        print("FIX 269 start auth challenge from central");
        print("FIX 273 ChalCent c03 $challenge");
        await authChallengeFromCentral!.write(challenge, allowLongWrite: true);

        print("FIX 272 finsh auth challenge from central");
        List<int> response;
        int attempts = 0;
        await Future.delayed(const Duration(seconds: 1));

        print("FIX <<<<READ FROM ALL CHARACTERISTICS");
        for (int i = 0; i < readCharacteristics.length; i++) {
          BluetoothCharacteristic? bChar = readCharacteristics[i];
          if (bChar == null) {
            print("FIX null characteristic does not exist");
          } else {
            print("FIX print for ${bChar.characteristicUuid}");
            print("FIX values ${await bChar.read()}");
          }
        }
        while (true) {
          print("FIX 276 authenticate attepmt $attempts");

          response = await authResponseFromPeripheral.read();

          print(
              "FIX 278 RespPeri 750 ${authResponseFromPeripheral.characteristicUuid}");
          print("FIX 278 RespPeri 750  $response");
          if (response.any((byte) => byte != 0)) {
            print("FIX 281 check if bytes do not equal 0");
            break;
          }

          await Future.delayed(const Duration(seconds: 1));
          attempts++;
          if (attempts >= 10) {
            print("FIX 286 authentication timed out");
            emit(ChildDeviceErrorState(
                state, "Device authentication timed out."));
            await device.disconnect();
            return;
          }
        }

        List<int> weAreAuthenticated = await centralAuthenticated!.read();
        if (weAreAuthenticated.isEmpty || weAreAuthenticated[0] == 0) {
          emit(ChildDeviceErrorState(state,
              "Failed to authenticate. Check the password and pair again with the correct password."));
          await device.disconnect();
          return;
        }

        List<int> expectedResponse = _solveAuthChallenge(challenge, key);
        if (!listEquals(response, expectedResponse)) {
          emit(ChildDeviceErrorState(state,
              "Failed to authenticate device. Check you are connecting to the right device."));
          await device.disconnect();
          return;
        }
      }
      print("FIX 303 authnetication success");

      // Get sample count
      await acknowledgement!.write([1]);
      print("FIX popup shown here");
      int sampleCount = 0;
      {
        List<int> progressValue = await progress!.read();
        print("FIX popup shown after first read");
        for (int i = 0; i < progressValue.length; i++) {
          sampleCount |= progressValue[i] << (8 * i);
        }
      }
      print("FIX popup shown here //read sensor data");
      // Read sensor data
      int samplesRead = 0;
      int sampleCharacteristicIndex = 0;
      List<List<int>> values = [];
      emit(ChildDeviceSyncingState(state, 0));
      while (true) {
        BluetoothCharacteristic sampleCharacteristic =
            sampleData[sampleCharacteristicIndex]!;
        List<int> value = await sampleCharacteristic.read();

        sampleCharacteristicIndex++;
        if (sampleCharacteristicIndex >= sampleData.length) {
          sampleCharacteristicIndex = 0;
          await acknowledgement.write([1]);
        }
        print("FIX popup shown here before checking byte == 0");
        if (value.every((byte) => byte == 0)) {
          break;
        }

        values.add(value);

        while (value.length % ChildDeviceRepository.bytesPerSample != 0) {
          value.removeLast();
        }
        samplesRead += value.length ~/ ChildDeviceRepository.bytesPerSample;
        emit(ChildDeviceSyncingState(
            state, (samplesRead / sampleCount).clamp(0, 1)));
      }

      // Send samples to repository
      for (List<int> value in values) {
        await _repo.parseAndSaveSamples(childName, value, childId);
      }

      emit(ChildDeviceSyncSuccessState(state));
    } catch (e) {
      emit(ChildDeviceErrorState(state, "An error occurred: $e"));
    } finally {
      try {
        print("FIX 359 start disconnect");
        await device.disconnect();
        print("FIX 359 finsih disconnect");
      } catch (e) {
        print("FIX Last error catching ");
        print(e.toString);
      }
    }
  }
}
