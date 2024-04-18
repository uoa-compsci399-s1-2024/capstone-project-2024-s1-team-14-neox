import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/child_device_model.dart';
import '../domain/child_device_repository.dart';



part 'all_child_profile_state.dart';

class AllChildProfileCubit extends Cubit<AllChildProfileState> {
  final ChildDeviceRepository _childDeviceRepository;
  AllChildProfileCubit(this._childDeviceRepository) : super(AllChildProfileState());

  Future<void> fetchChildProfiles() async {
    try {
      final List<ChildDeviceModel> profiles = await _childDeviceRepository.fetchChildProfiles();
      emit(state.copyWith(
          status: AllChildProfileStatus.fetchSuccess, profiles: profiles));
    } on Exception {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The child profiles cannot be fetched."));
    }
  }

  Future<void> createChildProfile(String name, DateTime birthDate) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));
    try {
      final List<ChildDeviceModel>  childDeviceProfiles =
          await _childDeviceRepository.createChildProfile(name, birthDate);
      emit(state.copyWith(
        status: AllChildProfileStatus.addSuccess,
        profiles: childDeviceProfiles,
        message: "The child profile has been added",
      ));
      print("The child profile has been added");
    } on Exception catch (e) {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The child profile cannot be created."));
      print("The child profile has not been added");
      print(e.toString());
    }
  }

  Future<void> deleteChildProfile(int childId) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));
    try {
      final childDeviceProfiles = await _childDeviceRepository.deleteChildProfile(childId);
      emit(state.copyWith(
        status: AllChildProfileStatus.deleteSuccess,
        profiles: childDeviceProfiles,
        message: "The child profile has been deleted",
      ));
    } on Exception {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The child profile cannot be deleted."));
    }
  }

  Future<void> updateDeviceRemoteId(
      {required int? childId, required String deviceRemoteId}) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));

    final childDeviceProfiles =
        await _childDeviceRepository.updateChildDeviceRemoteID(childId, deviceRemoteId);
    emit(state.copyWith(
        status: AllChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully updated device"));
  }

    Future<void> deleteDeviceRemoteId(
      {required int? childId}) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));

    final childDeviceProfiles =
        await _childDeviceRepository.deleteChildDeviceRemoteID(childId);
    emit(state.copyWith(
        status: AllChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully unpaired device"));
  }

}

