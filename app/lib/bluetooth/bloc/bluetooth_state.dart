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

class BluetoothConnectLoadingState extends BluetoothState {
  const BluetoothConnectLoadingState({ required super.scanResults });
}

class BluetoothConnectSuccessState extends BluetoothState {
  final String newDeviceRemoteId;
  const BluetoothConnectSuccessState({ required super.scanResults, required this.newDeviceRemoteId });
}

class BluetoothErrorState extends BluetoothState {
  final String errorMessage;

  const BluetoothErrorState({ required super.scanResults, required this.errorMessage });
}
