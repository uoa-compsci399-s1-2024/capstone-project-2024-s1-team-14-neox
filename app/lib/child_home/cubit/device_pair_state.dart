part of 'device_pair_cubit.dart';

enum DevicePairStatus {
  unknown,
  paired,
  pairSuccess,
  unpairSuccess,
  failure,
  loading,
}

extension DevicePairStatusX on DevicePairStatus {
  bool get isUnknown => this == DevicePairStatus.unknown;
  bool get isPaired => this == DevicePairStatus.paired;
  bool get isPairSuccess => this == DevicePairStatus.pairSuccess;
  bool get isUnpairSuccess => this == DevicePairStatus.unpairSuccess;
  bool get isFailure => this == DevicePairStatus.failure;
  bool get isLoading => this == DevicePairStatus.loading;
}

class DevicePairState extends Equatable {
  final DevicePairStatus status;
  final String? deviceRemoteId;
  final String message;
  final String childName;

  const DevicePairState({
    required this.status,
    required this.childName,
    required this.deviceRemoteId,
    this.message = "",
  });

  DevicePairState copyWith({
    DevicePairStatus? status,
    String? childName,
    String? deviceRemoteId,
    String? message,
  }) {
    return DevicePairState(
      status: status ?? this.status,
      childName: childName ?? this.childName,
      deviceRemoteId: deviceRemoteId ?? "",
      message: message ?? "",
    );
  }

  @override
  List<Object?> get props => [status, deviceRemoteId, message];
}