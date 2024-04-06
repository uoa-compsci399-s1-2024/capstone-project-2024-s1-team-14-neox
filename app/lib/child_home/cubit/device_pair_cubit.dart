import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'device_pair_state.dart';

class DevicePairCubit extends Cubit<DevicePairState> {
  final String name;
  String? deviceRemoteId;
  DevicePairCubit(this.name, this.deviceRemoteId)
      : super(deviceRemoteId != null
            ? DevicePairState(
                status: DevicePairStatus.paired, deviceRemoteId: deviceRemoteId)
            : DevicePairState(
                status: DevicePairStatus.unknown,
                deviceRemoteId: deviceRemoteId));

  void onDevicePairSuccess(String id) {
    deviceRemoteId = id;
    emit(state.copyWith(
      status: DevicePairStatus.pairSuccess,
      deviceRemoteId: deviceRemoteId,
      message: "Successfully paired device",
    ));
  }

  void onDeviceUnpairSuccess() {
    deviceRemoteId = null;
    emit(state.copyWith(
      status: DevicePairStatus.unpairSuccess,
      deviceRemoteId: deviceRemoteId,
      message: "Successfully unpaired device",
    ));
  }

  void onDevicePairFailure(String errorMessage) {
    state.copyWith(
      status: DevicePairStatus.failure,
      message: errorMessage,
    );
  }
}
