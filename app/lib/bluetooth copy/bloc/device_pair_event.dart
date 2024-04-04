part of 'device_pair_bloc.dart';

@immutable
sealed class DevicePairEvent {}

class DeviceBluetoothInitialse extends DevicePairEvent {}

class DeviceScanStartPressed extends DevicePairEvent {}

class DeviceScanStopPressed extends DevicePairEvent {}

class DevicePairPressed extends DevicePairEvent {

}

class DeviceUnpairPressed extends DevicePairEvent {}

class DeviceConnectPressed extends DevicePairEvent {
  final BluetoothDevice bluetoothDevice;

  DeviceConnectPressed({required this.bluetoothDevice});
}

class DeviceSyncPressed extends DevicePairEvent {}

class DeviceResetPressed extends DevicePairEvent {}
