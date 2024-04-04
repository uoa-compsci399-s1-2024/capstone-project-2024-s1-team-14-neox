part of 'bluetooth_bloc.dart';

sealed class BluetoothEvent{}


class BluetoothScanStartPressed extends BluetoothEvent {} 
class BluetoothScanStopPressed extends BluetoothEvent {} 
class BluetoothPairPressed extends BluetoothEvent {} 
class BluetoothUnpairPressed extends BluetoothEvent {}
class BluetoothConnectPressed extends BluetoothEvent {}
class BluetoothSyncPressed extends BluetoothEvent {} 