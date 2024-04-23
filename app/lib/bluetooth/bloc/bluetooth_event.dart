part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent {}

class BluetoothScanStarted extends BluetoothEvent {}

class BluetoothConnectPressed extends BluetoothEvent {
  final String deviceRemoteId;

  BluetoothConnectPressed({required this.deviceRemoteId});
}
