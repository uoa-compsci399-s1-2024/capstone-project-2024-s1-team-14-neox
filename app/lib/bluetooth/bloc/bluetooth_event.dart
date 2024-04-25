part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent {}

class BluetoothScanStarted extends BluetoothEvent {}

class BluetoothAuthCodeEntered extends BluetoothEvent {
  final String deviceRemoteId;
  final String authorisationCode;

  BluetoothAuthCodeEntered({required this.deviceRemoteId, required this.authorisationCode});
}

class BluetoothConnectPressed extends BluetoothEvent {
  final String deviceRemoteId;

  BluetoothConnectPressed({required this.deviceRemoteId});
}
