part of 'bluetooth_bloc.dart';

class BluetoothState {
  final List<ScanResult> scanResults;

  const BluetoothState({ required this.scanResults });
}

class BluetoothIdleState extends BluetoothState {
  const BluetoothIdleState({ required super.scanResults });
}

class BluetoothScanLoadingState extends BluetoothState {
  const BluetoothScanLoadingState({ required super.scanResults });
}

class BluetoothAuthCodeInputState extends BluetoothState {
  final String deviceRemoteId;
  const BluetoothAuthCodeInputState({ required super.scanResults, required this.deviceRemoteId });
}

class BluetoothConnectSuccessState extends BluetoothState {
  final String newDeviceRemoteId;
  final String newAuthorisationCode;
  const BluetoothConnectSuccessState({
    required super.scanResults,
    required this.newDeviceRemoteId,
    required this.newAuthorisationCode
  });
}

class BluetoothErrorState extends BluetoothState {
  final String errorMessage;

  const BluetoothErrorState({ required super.scanResults, required this.errorMessage });
}
