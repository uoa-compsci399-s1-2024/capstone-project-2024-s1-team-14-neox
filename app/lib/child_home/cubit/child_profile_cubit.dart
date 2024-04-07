import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/child_device_model.dart';
import '../domain/child_device_repository.dart';



part 'child_profile_state.dart';

class ChildProfileCubit extends Cubit<ChildProfileState> {
  final ChildDeviceRepository _childDeviceRepository;
  ChildProfileCubit(this._childDeviceRepository) : super(ChildProfileState());

  Future<void> fetchChildProfiles() async {
    try {
      final List<ChildDeviceModel> profiles = await _childDeviceRepository.fetchChildProfiles();
      emit(state.copyWith(
          status: ChildProfileStatus.fetchSuccess, profiles: profiles));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profiles cannot be fetched."));
    }
  }

  Future<void> createChildProfile(String name, DateTime birthDate) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));
    try {
      final List<ChildDeviceModel>  childDeviceProfiles =
          await _childDeviceRepository.createChildProfile(name, birthDate);
      emit(state.copyWith(
        status: ChildProfileStatus.addSuccess,
        profiles: childDeviceProfiles,
        message: "The child profile has been added",
      ));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profile cannot be created."));
    }
  }

  Future<void> deleteChildProfile(int childId) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));
    try {
      final childDeviceProfiles = await _childDeviceRepository.deleteChildProfile(childId);
      emit(state.copyWith(
        status: ChildProfileStatus.deleteSuccess,
        profiles: childDeviceProfiles,
        message: "The child profile has been deleted",
      ));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profile cannot be deleted."));
    }
  }

  Future<void> updateDeviceRemoteId(
      {required int childId, required String? deviceRemoteId}) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));

    final childDeviceProfiles =
        await _childDeviceRepository.updateChildDeviceRemoteID(childId, deviceRemoteId ?? "");
    emit(state.copyWith(
        status: ChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully updated device"));
  }

}
