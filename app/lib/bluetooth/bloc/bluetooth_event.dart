part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent {}

class BluetoothScanStartPressed extends BluetoothEvent {}

class BluetoothScanStopPressed extends BluetoothEvent {}

class BluetoothConnectPressed extends BluetoothEvent {
  final String deviceRemoteId;

  BluetoothConnectPressed({required this.deviceRemoteId});
}

class BluetoothDisconnectPressed extends BluetoothEvent {
  final String deviceRemoteId;
  BluetoothDisconnectPressed({required this.deviceRemoteId});
}

class BluetoothSyncPressed extends BluetoothEvent {
  final int childId;
  final String childName;
  final String deviceRemoteId;
  final String authorisationCode;

  BluetoothSyncPressed({
    required this.childId,
    required this.childName,
    required this.deviceRemoteId,
    required this.authorisationCode});
}
