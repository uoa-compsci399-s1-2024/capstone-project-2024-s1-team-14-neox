part of 'bluetooth_bloc.dart';

enum BluetoothStatus {
  unknown,
  scanLoading,
  scanStopped,
  pairLoading,
  pairComplete,
  syncLoading,
  syncComplete,
  error,
}

// Extension so that we can check status using if (state.status.isUnknown) in the BlocBuilder/BlocListener

extension BluetoothStatusX on BluetoothStatus {
  bool get isUnknown => this == BluetoothStatus.unknown;
  bool get isScanLoading => this == BluetoothStatus.scanLoading;
  bool get isScanStopped => this == BluetoothStatus.scanStopped;
  bool get isPairLoading => this == BluetoothStatus.pairLoading;
  bool get isPairComplete => this == BluetoothStatus.pairComplete;
  bool get isSyncLoading => this == BluetoothStatus.syncLoading;
  bool get isSyncComplete => this == BluetoothStatus.syncComplete;
  bool get isError => this == BluetoothStatus.error;
}

class BluetoothState extends Equatable {
  final BluetoothStatus status;
  final List<BluetoothDevice> systemDevices;
  final List<ScanResult> scanResults;
  final String childId;
  final String message;

  const BluetoothState({
    this.status = BluetoothStatus.unknown,
    this.systemDevices = const <BluetoothDevice>[],
    this.scanResults = const <ScanResult>[],
    this.childId = "",
    this.message = "",
  });
  BluetoothState copyWith({
    BluetoothStatus? status,
    List<BluetoothDevice>? systemDevices,
    List<ScanResult>? scanResults,
    String? childId,
    String? message,
  }) {
    return BluetoothState(
      status: status ?? this.status,
      systemDevices: systemDevices ?? this.systemDevices,
      scanResults: scanResults ?? this.scanResults,
      childId: childId ?? "",
      message: message ?? "",
    );
  }

  @override
  List<Object?> get props =>
      [status, systemDevices, scanResults, childId, message];
}
