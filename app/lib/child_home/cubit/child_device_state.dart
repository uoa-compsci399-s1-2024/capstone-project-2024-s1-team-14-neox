part of 'child_device_cubit.dart';

class ChildDeviceState {
  final int childId;
  final String childName;
  final DateTime birthDate;
  final String deviceRemoteId;
  final String authorisationCode;

  const ChildDeviceState({
    required this.childId,
    required this.childName,
    required this.birthDate,
    required this.deviceRemoteId,
    required this.authorisationCode,
  });
}

class ChildDeviceIdleState extends ChildDeviceState {
  ChildDeviceIdleState(ChildDeviceState childDeviceState) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: childDeviceState.deviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceErrorState extends ChildDeviceState {
  final String errorMessage;

  ChildDeviceErrorState(ChildDeviceState childDeviceState, this.errorMessage) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: childDeviceState.deviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceLoadingState extends ChildDeviceState {
  ChildDeviceLoadingState(ChildDeviceState childDeviceState) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: childDeviceState.deviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceConnectState extends ChildDeviceState {
  ChildDeviceConnectState(ChildDeviceState childDeviceState, String newDeviceRemoteId) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: newDeviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceDisconnectState extends ChildDeviceState {
  ChildDeviceDisconnectState(ChildDeviceState childDeviceState) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: "",
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceSyncingState extends ChildDeviceState {
  final double? progress; // In range [0,1] or null when sync is still starting (e.g. auth)

  ChildDeviceSyncingState(ChildDeviceState childDeviceState, this.progress) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: childDeviceState.deviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}

class ChildDeviceSyncSuccessState extends ChildDeviceState {
  ChildDeviceSyncSuccessState(ChildDeviceState childDeviceState) : super(
    childId: childDeviceState.childId,
    childName: childDeviceState.childName,
    birthDate: childDeviceState.birthDate,
    deviceRemoteId: childDeviceState.deviceRemoteId,
    authorisationCode: childDeviceState.authorisationCode,
  );
}
