part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent{}


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
    final String childName;
    final String deviceRemoteId;

  BluetoothSyncPressed({required this.childName, required this.deviceRemoteId});
} 