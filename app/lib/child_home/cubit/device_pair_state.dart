part of 'device_pair_cubit.dart';

// Put in if using Equatable, deprecated
// enum DevicePairStatus {
//   unknown,
//   paired,
//   pairSuccess,
//   unpairSuccess,
//   failure,
//   loading,
// }

// extension DevicePairStatusX on DevicePairStatus {
//   bool get isUnknown => this == DevicePairStatus.unknown;
//   bool get isPaired => this == DevicePairStatus.paired;
//   bool get isPairSuccess => this == DevicePairStatus.pairSuccess;
//   bool get isUnairSuccess => this == DevicePairStatus.unpairSuccess;
//   bool get isFailure => this == DevicePairStatus.failure;
//   bool get isLoading => this == DevicePairStatus.loading;
// }


sealed class DevicePairState{}

final class DevicePairLoading extends DevicePairState {}

final class DevicePairUnknown extends DevicePairState{}

final class DevicePaired extends DevicePairState {}


final class DevicePairSuccess extends DevicePairState {
  final String message;

  DevicePairSuccess({required this.message});
}
final class DevicePairFailure extends DevicePairState {
  final String message;

  DevicePairFailure({required this.message});

}
final class DeviceUnpairSuccess extends DevicePairState {
  final String message;

  DeviceUnpairSuccess({required this.message});
  
}
