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
  final ChildDeviceRepository _repo;

  ChildDeviceCubit({
    required ChildDeviceRepository repo,
    required int childId,
    required String childName,
    required DateTime birthDate,
    required String gender,
    required String deviceRemoteId,
    required String authorisationCode,
    required int outdoorTimeToday,
    required int outdoorTimeWeek,
    required int outdoorTimeMonth,
  })  : _repo = repo,
        super(ChildDeviceIdleState(ChildDeviceState(
          childId: childId,
          childName: childName,
          birthDate: birthDate,
          gender: gender,
          deviceRemoteId: deviceRemoteId,
          authorisationCode: authorisationCode,
          outdoorTimeToday: outdoorTimeToday,
          outdoorTimeWeek: outdoorTimeWeek,
          outdoorTimeMonth: outdoorTimeMonth,
        )));

  void onChildDeviceConnectPressed(
      String deviceRemoteId, String authorisationCode) {
    emit(ChildDeviceConnectState(state, deviceRemoteId, authorisationCode));
  }

  void onChildDeviceDisconnectPressed() {
    emit(ChildDeviceDisconnectState(state));
  }

  static List<int> _solveAuthChallenge(List<int> challenge, List<int> key) {
    if (challenge.length != 20) {
      print("Sync length from challenge is ${challenge.length}");
      // if (challenge.length != 16) {
      // If the device sends us an invalid challenge,
      // we might as well send them back an invalid response :P
      return [];
    }
    print("Sync after chekcing length is not 20");

    List<int> combined = [];
    for (int i = 0; i < challenge.length; i++) {
      combined.add(challenge[i] ^ key[i]);
    }
    
    while (combined.length < 32) {
      combined.add(0);
    }
    print("Sync auth challenge solved ${sha256.convert(combined).bytes}");

    return sha256.convert(combined).bytes.sublist(0, 20);
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
      await for (List<ScanResult> scanResults
          in FlutterBluePlus.scanResults.timeout(const Duration(seconds: 15))) {
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

    print("Sync on sync pressed ${DateTime.now()}");

    try {
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      }
      emit(ChildDeviceSyncingState(state, null));
      device = await _getBluetoothDevice(deviceRemoteId);
    } catch (e) {
      emit(ChildDeviceErrorState(state, "Failed to turn on Bluetooth: $e"));
      return;
    }

    if (device == null) {
      emit(ChildDeviceErrorState(state, "Device not found nearby."));
      return;
    }
    print("Classify trying to connect");
    try {
      await device.connect(mtu: 23);
    } catch (e) {
      emit(ChildDeviceErrorState(state, "Failed to connect to device: $e"));
      return;
    }

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
    const String uuidTimestamp = "f06c06bb-0006-4f4c-b6b4-a146eff5ab15";
    const String uuidProgress = "f06c06bb-0007-4f4c-b6b4-a146eff5ab15";

    final bsSubscription = device.bondState.listen((value) {
      print("Sync bond state changed$value prev:${device?.prevBondState}");
    });

    print("Sync listening to bonding");
// cleanup: cancel subscription when disconnected
    device.cancelWhenDisconnected(bsSubscription);

    try {
      await device.requestConnectionPriority(
          connectionPriorityRequest: ConnectionPriority.high);

      // Find characteristics
      List<BluetoothCharacteristic?> sampleData = [];
      BluetoothCharacteristic? acknowledgement;
      BluetoothCharacteristic? authChallengeFromPeripheral;
      BluetoothCharacteristic? authResponseFromCentral;
      BluetoothCharacteristic? authChallengeFromCentral;
      BluetoothCharacteristic? authResponseFromPeripheral;
      BluetoothCharacteristic? centralAuthenticated;
      BluetoothCharacteristic? timestamp;
      BluetoothCharacteristic? progress;
      sampleData.length = uuidSamples.length;
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() != uuidSerivce) {
          continue;
        }

        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
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
          } else if (characteristicUuid == uuidTimestamp) {
            timestamp = characteristic;
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

      // only read

      print("Sync check if all characteristics are found");

      // Check if all characteristics are found
      List<BluetoothCharacteristic?> writeCharacteristics = [
        acknowledgement,
        authResponseFromCentral,
        authChallengeFromCentral,
        authResponseFromPeripheral,
        timestamp,
      ];
      List<BluetoothCharacteristic?> readCharacteristics = [
        ...sampleData,
        authChallengeFromPeripheral,
        authResponseFromPeripheral,
        centralAuthenticated,
        progress,
      ];

      if (readCharacteristics
              .any((char) => char == null || !char.properties.read) ||
          writeCharacteristics
              .any((char) => char == null || !char.properties.write)) {
        emit(ChildDeviceErrorState(state, "Service missing characteristics"));
        return;
      }
      final authChalPeriSubscription =
          authChallengeFromPeripheral!.onValueReceived.listen((value) {
        print("Sync auth chall from peri read $value ${DateTime.now()}");
      });
      device.cancelWhenDisconnected(authChalPeriSubscription);

      final authRespPeriSubscription =
          authResponseFromPeripheral!.onValueReceived.listen((value) {
        print("Sync auth resp from peri read $value ${DateTime.now()}");
      });
      device.cancelWhenDisconnected(authRespPeriSubscription);
      // final authRespPeriSubscription =
      //     authChallengeFromPeripheral!.onValueReceived.listen((value) {
      //   print("Sync auth resp from peri read $value ${DateTime.now()}");
      // });
      // device.cancelWhenDisconnected(authRespPeriSubscription);
      // final authRespPeriSubscription =
      //     authChallengeFromPeripheral!.onValueReceived.listen((value) {
      //   print("Sync auth resp from peri read $value ${DateTime.now()}");
      // });
      // device.cancelWhenDisconnected(authRespPeriSubscription);

      // Authenticate us
      if (authorisationCode.length != 10 ||
          authorisationCode.codeUnits.any((c) => c >= 128)) {
        emit(
            ChildDeviceErrorState(state, "Invalid authorisation code format."));
        return;
      }
      List<int> key = [...authorisationCode.codeUnits];
      while (key.length < 20) {
        key.add(0);
      }
      print("Sync begin authentication");
      {
        List<int> challenge =
            await authChallengeFromPeripheral!.read().then((value) {
          print("Sync auth chall from peri then ${DateTime.now()}");
          return value;
        });
        print("Sync auth chall from peri after ${DateTime.now()}");
        List<int> response = _solveAuthChallenge(challenge, key);
        print("Sync auth chall from peri after ${DateTime.now()}");
        print("Sync ========");
        //not syncing from here
        print("Sync auth respo from cent sending ${response}");
        await authResponseFromCentral!
            .write(response, allowLongWrite: true)
            .then((value) {
          print("sync writing $response to peripheral");
          print("Sync auth resp from central then ${DateTime.now()}");
          return value;
        });
        print("Sync auth resp from central after ${DateTime.now()}");
      }
      print("Sync ========");

      // Authenticate them
      {
        List<int> generatedAuthResponseFromPeripheral = List.generate(20, (_) => 0);
        await authResponseFromPeripheral!
            .write(generatedAuthResponseFromPeripheral, allowLongWrite: true)
            .then((value) {
              print("Sync auth respo from peripheral ${generatedAuthResponseFromPeripheral}");
          print("Sync auth resp from peri then ${DateTime.now()}");
          return value;
        });
        print("Sync auth resp from peri after ${DateTime.now()}");

        List<int> challenge =
            List.generate(20, (index) => Random.secure().nextInt(256));
        print("Sync values for auth chall from Central ${challenge}");
        await authChallengeFromCentral!
            .write(challenge, allowLongWrite: true)
            .then((value) {
              print("Sync auth chall from central ${challenge}");
          print("Sync auth chall from cent then ${DateTime.now()}");
          return value;
        });
        print("Sync auth chall from cent after ${DateTime.now()}");

        List<int> response;
        int attempts = 0;
        while (true) {
          print("inside while loop ${DateTime.now()}");
          response = await authResponseFromPeripheral.read().then((value) {
            print("Sync auth Resp from Peri then ${DateTime.now()}");
            return value;
          });
          print("Sync after auth resp from peri ${DateTime.now()}");
          if (response.any((byte) => byte != 0)) {
            break;
          }

          print("Sync values for auth chall from Central ${challenge}");
          await Future.delayed(const Duration(seconds: 1));
          attempts++;
          if (attempts >= 10) {
            emit(ChildDeviceErrorState(
                state, "Device authentication timed out."));
            return;
          }
        }

        List<int> weAreAuthenticated =
            await centralAuthenticated!.read().then((value) {
          print("sync cent auth read then ${DateTime.now()}");
          return value;
        });
        print("sync cent auth read after ${DateTime.now()}");
        if (weAreAuthenticated.isEmpty || weAreAuthenticated[0] == 0) {
          emit(ChildDeviceErrorState(state,
              "Failed to authenticate. Check the password and pair again with the correct password."));
          return;
        }

        List<int> expectedResponse = _solveAuthChallenge(challenge, key);
        // if (!listEquals(response, expectedResponse)) {
        //   emit(ChildDeviceErrorState(state,
        //       "Failed to authenticate device. Check you are connecting to the right device."));
        //   return;
        //}
      }
      print("Sync get most recent timestamp");

      // Get sample count
      int mostRecentSampleTimestamp =
          await _repo.getMostRecentSampleTimestamp(childId);
      await timestamp!.write([
        mostRecentSampleTimestamp & 0xFF,
        (mostRecentSampleTimestamp >> 8) & 0xFF,
        (mostRecentSampleTimestamp >> 16) & 0xFF,
        (mostRecentSampleTimestamp >> 24) & 0xFF,
      ]).then((value) {
        print("Sync most recent timestamp write then ${DateTime.now()}");
      });
      print("Sync most recent timestamp write after ${DateTime.now()}");

      await acknowledgement!.write([1]).then(
        (value) {
          print("Sync acknowledgement write complete then ${DateTime.now()}");
        },
      );

      print("Sync acknowledgement write complete then ${DateTime.now()}");
      int sampleCount = 0;
      {
        List<int> progressValue = await progress!.read();
        for (int i = 0; i < progressValue.length; i++) {
          sampleCount |= progressValue[i] << (8 * i);
        }
      }

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
          await acknowledgement!.write([1]).then(
            (value) {
              print(
                  "Sync acknowledgement write complete then ${DateTime.now()}");
            },
          );

          print("Sync acknowledgement write complete then ${DateTime.now()}");
        }

        if (value.every((byte) => byte == 0)) {
          break;
        }
    print("Sync velue received {value}");
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
            print("Sync finally clause");
        await device.disconnect().then((value) {
          print("sync disconnected finished");
        });
            print("Sync finally after");
      } catch (e) {
        // Ignore
      }
    }
  }
}
