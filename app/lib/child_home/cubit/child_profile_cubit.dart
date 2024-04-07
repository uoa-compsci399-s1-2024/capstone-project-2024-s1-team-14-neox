import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/child_model.dart';
import '../../data/child_repository.dart';

part 'child_profile_state.dart';

class ChildProfileCubit extends Cubit<ChildProfileState> {
  final ChildRepository _childRepository;
  ChildProfileCubit(this._childRepository) : super(ChildProfileState());

  Future<void> fetchChildProfiles() async {
    try {
      final childProfiles = _childRepository.fetchChildProfiles();
      emit(state.copyWith(
          status: ChildProfileStatus.fetchSuccess, profiles: childProfiles));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profiles cannot be fetched."));
    }
  }

  Future<void> createChildProfile(String name, DateTime dateOfBirth) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));
    try {
      final childProfiles =
          await _childRepository.createChildProfile(name, dateOfBirth);
      emit(state.copyWith(
        status: ChildProfileStatus.addSuccess,
        profiles: childProfiles,
        message: "The child profile has been added",
      ));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profile cannot be created."));
    }
  }

  Future<void> deleteChildProfile(int index) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));
    try {
      final childProfiles = await _childRepository.deleteChildProfile(index);
      emit(state.copyWith(
        status: ChildProfileStatus.deleteSuccess,
        profiles: childProfiles,
        message: "The child profile has been deleted",
      ));
    } on Exception {
      emit(state.copyWith(
          status: ChildProfileStatus.failure,
          message: "The child profile cannot be deleted."));
    }
  }

  Future<void> updateDeviceRemoteId(
      {required String name, required String? deviceRemoteId}) async {
    emit(state.copyWith(status: ChildProfileStatus.loading));

    final childProfiles =
        await _childRepository.updateChildDeviceRemoteID(name, deviceRemoteId);
    emit(state.copyWith(
        status: ChildProfileStatus.updateSuccess,
        profiles: childProfiles,
        message: "Successfully updated device"));
  }

}
