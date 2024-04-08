import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'child_device_state.dart';

class ChildDeviceCubit extends Cubit<ChildDeviceState> {
  ChildDeviceCubit(
      {required int? childId,
      required String childName,
      required DateTime birthDate,
      String? deviceRemoteId,
      String? authorisationCode})
      : super(deviceRemoteId != null
            ? ChildDeviceState(
                status: ChildDeviceStatus.paired,
                childId: childId,
                childName: childName,
                birthDate: birthDate,
                deviceRemoteId: deviceRemoteId,
                authorisationCode: authorisationCode,
              )
            : ChildDeviceState(
                status: ChildDeviceStatus.unknown,
                childId: childId,
                childName: childName,
                birthDate: birthDate,
                deviceRemoteId: deviceRemoteId,
                authorisationCode: authorisationCode,
              ));

  void onChildDevicePairSuccess(String deviceRemoteId) {
    emit(state.copyWith(
      status: ChildDeviceStatus.pairSuccess,
      deviceRemoteId: deviceRemoteId,
      message: "Successfully paired device",
    ));
  }

  void onChildDeviceUnpairSuccess() {
    emit(state.copyWith(
      status: ChildDeviceStatus.unpairSuccess,
      deviceRemoteId: null,
      message: "Successfully unpaired device",
    ));
  }

  void onChildDevicePairFailure(String errorMessage) {
    state.copyWith(
      status: ChildDeviceStatus.failure,
      message: errorMessage,
    );
  }

  // TODO implement delete child
}
