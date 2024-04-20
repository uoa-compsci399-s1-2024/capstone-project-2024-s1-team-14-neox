part of 'child_device_cubit.dart';

enum ChildDeviceStatus {
  unknown,
  paired,
  pairSuccess,
  unpairSuccess,
  failure,
  loading,
}

extension ChildDeviceStatusX on ChildDeviceStatus {
  bool get isUnknown => this == ChildDeviceStatus.unknown;
  bool get isPaired => this == ChildDeviceStatus.paired;
  bool get isPairSuccess => this == ChildDeviceStatus.pairSuccess;
  bool get isUnpairSuccess => this == ChildDeviceStatus.unpairSuccess;
  bool get isFailure => this == ChildDeviceStatus.failure;
  bool get isLoading => this == ChildDeviceStatus.loading;
}

class ChildDeviceState extends Equatable {
  final ChildDeviceStatus status;
  final int childId;
  final String childName;
  final DateTime birthDate;
  final String? deviceRemoteId;
  final String? authorisationCode;
  final String message;

  const ChildDeviceState({
    required this.childId,
    required this.status,
    required this.childName,
    required this.birthDate,
    required this.deviceRemoteId,
    required this.authorisationCode,
    this.message = "",
  });

  ChildDeviceState copyWith({
    ChildDeviceStatus? status,
    int? childId,
    String? childName,
    DateTime? birthDate,
    String? deviceRemoteId,
    String? message,
  }) {
    return ChildDeviceState(
      status: status ?? this.status,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      birthDate: birthDate ?? this.birthDate,
      deviceRemoteId: deviceRemoteId ?? "",
      authorisationCode: authorisationCode ?? "",
      message: message ?? "",
    );
  }

  @override
  List<Object?> get props => [
        status,
        childId,
        childName,
        deviceRemoteId,
        authorisationCode,
        message,
      ];
}
