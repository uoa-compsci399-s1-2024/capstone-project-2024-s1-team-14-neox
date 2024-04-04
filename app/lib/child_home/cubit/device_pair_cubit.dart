
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/child_model.dart';
import '../../data/child_repository.dart';

part 'device_pair_state.dart';

class DevicePairCubit extends Cubit<DevicePairState> {
  final ChildRepository _childRepository;
  final ChildModel profile;
  DevicePairCubit(this._childRepository, this.profile) : super(
    profile.device != null
    ? DevicePaired()
    : DevicePairUnknown()
  );

  void onDevicePairSuccess() {
    emit(DevicePairSuccess(message: "Successfully paired device"));
  }
  void onDeviceUnpairSuccess() {
    emit(DeviceUnpairSuccess(message: "Successfully unpaired device"));
  }
  void onDevicePairFailure(String errorMessage) {
    emit(DeviceUnpairSuccess(message: "errorMessage"));
  }

}
