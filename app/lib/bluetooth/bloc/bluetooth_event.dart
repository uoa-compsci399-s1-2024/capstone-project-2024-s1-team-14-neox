part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent{}


class BluetoothScanStartPressed extends BluetoothEvent {} 
class BluetoothScanStopPressed extends BluetoothEvent {} 
class BluetoothPairPressed extends BluetoothEvent {} 
class BluetoothUnpairPressed extends BluetoothEvent {}
class BluetoothConnectPressed extends BluetoothEvent {
  final BluetoothDevice device;

  BluetoothConnectPressed({required this.device});

}
class BluetoothSyncPressed extends BluetoothEvent {
    final BluetoothDevice device;

  BluetoothSyncPressed({required this.device});
} 