
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'device_pair_state.dart';

class DevicePairCubit extends Cubit<DevicePairState> {
  final String name;
  final String? deviceRemoteId;
  DevicePairCubit(this.name, this.deviceRemoteId) : super(
    deviceRemoteId != null
    ? DevicePaired()
    : DevicePairUnknown()
  );

  void onDevicePairSuccess(String deviceRemoteId) {
    emit(DevicePairSuccess(message: "Successfully paired device"));
  }
  void onDeviceUnpairSuccess() {
    emit(DeviceUnpairSuccess(message: "Successfully unpaired device"));
  }
  void onDevicePairFailure(String errorMessage) {
    emit(DeviceUnpairSuccess(message: "errorMessage"));
  }

}
