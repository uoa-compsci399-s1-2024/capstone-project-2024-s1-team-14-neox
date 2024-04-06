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
  String uuidSample1 = "42b25f8f-0000-43de-92b8-47891c706106";
  String uuidSample2 = "5c5ef115-0001-431d-8c23-52ff6ad1e467";
  String uuidSample3 = "1fc0372f-0002-43f3-8cfc-1a5611b88062";
  String uuidSample4 = "ff3d9730-0003-4aac-84e2-0861c1d000a6";
  String uuidSample5 = "6eea8c3b-0004-4ec0-a842-6ed292e598dd";
  String uuidAcknowledgement = "f06c06bb-0005-4f4c-b6b4-a146eff5ab15";

  // Subscriptions

  // late StreamSubscription<List<int>> sample1StreamSubscription;
  // late StreamSubscription<List<int>> sample2StreamSubscription;
  // late StreamSubscription<List<int>> sample3StreamSubscription;
  // late StreamSubscription<List<int>> sample4StreamSubscription;
  // late StreamSubscription<List<int>> sample5StreamSubscription;

  

  late BluetoothCharacteristic acknowledgementCharacteristic;

  BluetoothBloc() : super(BluetoothState()) {
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

          List<StreamSubscription<List<int>>> sampleDataSubscriptions = [];



    if (event.deviceRemoteId == "") {
      emit(
        state.copyWith(
            status: BluetoothStatus.error, message: "No device paired"),
      );
    } else {
      BluetoothDevice device = BluetoothDevice.fromId(event.deviceRemoteId);
      if (device.isDisconnected) {
        await device.connect(mtu: 23);
        print(
            "${device.disconnectReason?.code} $device.disconnectReason?.description}");
      }

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == uuidSerivce) {
          List<BluetoothCharacteristic> characteristics =
              service.characteristics;
          for (BluetoothCharacteristic characteristic in characteristics) {
            String uuidFound =
                characteristic.characteristicUuid.toString().toLowerCase();

            //Sample 1
            if (uuidFound == uuidSample1) {
               StreamSubscription<List<int>> sample1StreamSubscription =
                  characteristic.onValueReceived.listen((byteArray) {
                print("Sample1: $byteArray");
              });
              if (!characteristic.isNotifying) {
                await characteristic.setNotifyValue(true);
                sampleDataSubscriptions.add(sample1StreamSubscription);
              }
              //Sample 2
            } else if (uuidFound == uuidSample2) {
               StreamSubscription<List<int>> sample2StreamSubscription =
                  characteristic.onValueReceived.listen((byteArray) {
                print("Sample2: $byteArray");
              });
              if (!characteristic.isNotifying) {
                await characteristic.setNotifyValue(true);
                sampleDataSubscriptions.add(sample2StreamSubscription);
              }
              //Sample 3
            } else if (uuidFound == uuidSample3) {
               StreamSubscription<List<int>> sample3StreamSubscription =
                  characteristic.onValueReceived.listen((byteArray) {
                print("Sample3: $byteArray");
              });
              if (!characteristic.isNotifying) {
                await characteristic.setNotifyValue(true);
                sampleDataSubscriptions.add(sample3StreamSubscription);
              }
              //Sample 4
            } else if (uuidFound == uuidSample4) {
               StreamSubscription<List<int>> sample4StreamSubscription =
                  characteristic.onValueReceived.listen((byteArray) {
                print("Sample4: $byteArray");
              });
              if (!characteristic.isNotifying) {
                await characteristic.setNotifyValue(true);
                sampleDataSubscriptions.add(sample4StreamSubscription);
              }
              //Sample 5
            } else if (uuidFound == uuidSample5) {
               StreamSubscription<List<int>> sample5StreamSubscription =
                  characteristic.onValueReceived.listen((byteArray) {
                print("Sample5: $byteArray");
              });
              if (!characteristic.isNotifying) {
                await characteristic.setNotifyValue(true);
                sampleDataSubscriptions.add(sample5StreamSubscription);
              }
            } else if (uuidFound == uuidAcknowledgement) {
              acknowledgementCharacteristic = characteristic;
            }
          }
        }
      }
      for (StreamSubscription<List<int>> subscription in sampleDataSubscriptions) {
        device.cancelWhenDisconnected(subscription);
      }
    }

    //TODO Call function to send byteArray to repository
    // Resources
    // https://github.com/boskokg/flutter_blue_plus/issues/274
    // https://pub.dev/packages/flutter_blue_plus#subscribe-to-a-characteristic
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
