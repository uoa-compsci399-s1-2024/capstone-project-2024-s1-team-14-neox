part of 'device_pair_bloc.dart';

// Single class with enum for states
// Used Single state class because the information is shared accross multiple states

enum DevicePairStatus {
  unknown,
  unpaired,
  scanLoading,
  scanStopped,
  pairLoading,
  paired,
  error,
}


// Extension so that we can check status using if (state.status.isUnknown) in the BlocBuilder/BlocListener
// Adapted from: https://github.com/VGVentures/supabase_example/blob/main/lib/account/bloc/account_state.dart

extension DevicePairStatusX on DevicePairStatus {
  bool get isUnknown => this == DevicePairStatus.unknown;
  bool get isUnpaired => this == DevicePairStatus.unpaired;
  bool get isScanLoading => this == DevicePairStatus.scanLoading;
  bool get isPairLoading => this == DevicePairStatus.pairLoading;
  bool get isPaired => this == DevicePairStatus.paired;
  bool get isError => this == DevicePairStatus.error;
}

@immutable
class DevicePairState extends Equatable {
  final DevicePairStatus status;
  final List<BluetoothDevice> systemDevices;
  final List<ScanResult> scanResults;
  final String errorMessage;

  const DevicePairState({
    this.status = DevicePairStatus.unknown,
    this.systemDevices = const <BluetoothDevice>[],
    this.scanResults = const <ScanResult>[],
    this.errorMessage = "",
  });

  // Added null check ? The parameter 'scanResults' can't have a value of 'null' because of its type, but the implicit default value is 'null'. Try adding either an explicit non-'null' default value or the 'required' modifier.
  DevicePairState copyWith({
    DevicePairStatus? status,
  List<BluetoothDevice>? systemDevices,
  List<ScanResult>? scanResults,
  String? errorMessage,
  }) {

    print("----SCANNING STATE---- ${scanResults}");
    return DevicePairState(
      
      status: status ?? this.status,
      systemDevices: systemDevices ?? this.systemDevices,
      scanResults: scanResults ?? this.scanResults,
      errorMessage: errorMessage ?? "",
    );
  }

  @override
  List<Object?> get props => [status, systemDevices, scanResults];
}

