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
      final List<ChildDeviceModel> profiles =
          await _childDeviceRepository.fetchChildProfiles();
      emit(state.copyWith(
          status: AllChildProfileStatus.fetchSuccess, profiles: profiles));
    } catch (e) {
      emit(
        state.copyWith(
            status: AllChildProfileStatus.failure,
            message: "The profiles cannot be fetched."),
      );
    }
  }

  Future<void> createChildProfile(String name, DateTime birthDate, String gender) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));
    try {
      final List<ChildDeviceModel> childDeviceProfiles =
          await _childDeviceRepository.createChildProfile(name, birthDate, gender);
      emit(state.copyWith(
        status: AllChildProfileStatus.addSuccess,
        profiles: childDeviceProfiles,
        message: "The profile has been added",
      ));
    } catch (e) {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The profile cannot be created."));
    }
  }

  Future<void> updateChildProfile(int childId, String name, DateTime birthDate, String gender, String authorisationCode) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));
    try {
      final List<ChildDeviceModel> childDeviceProfiles = await _childDeviceRepository.updateChildDetails(
        childId,
        name,
        birthDate,
        gender,
        authorisationCode,
      );
      emit(state.copyWith(
        status: AllChildProfileStatus.addSuccess,
        profiles: childDeviceProfiles,
        message: "The profile has been updated",
      ));
    } catch (e) {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The profile cannot be updated."));
    }
  }

  Future<void> deleteChildProfile(int childId) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));
    late List<ChildDeviceModel> childDeviceProfiles;
    try {
      childDeviceProfiles =
          await _childDeviceRepository.deleteChildProfile(childId);
    } catch (e) {
      emit(state.copyWith(
          status: AllChildProfileStatus.failure,
          message: "The profile cannot be deleted."));
    }
    await Future.delayed(
      const Duration(microseconds: 1000),
      () {
        emit(
          state.copyWith(
            status: AllChildProfileStatus.deleteSuccess,
            profiles: childDeviceProfiles,
            message: "The profile has been deleted",
          ),
        );
      },
    );
  }

  Future<void> updateDeviceRemoteId(
      {required int childId, required String deviceRemoteId}) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));

    final childDeviceProfiles = await _childDeviceRepository
        .updateChildDeviceRemoteID(childId, deviceRemoteId);
    emit(state.copyWith(
        status: AllChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully updated device"));
  }

  Future<void> updateAuthorisationCode(
      {required int childId, required String authorisationCode}) async {
    final childDeviceProfiles = await _childDeviceRepository
        .updateChildAuthenticationCode(childId, authorisationCode);
    emit(state.copyWith(
        status: AllChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully updated authentication code"));
  }

  Future<void> deleteDeviceRemoteId({required int childId}) async {
    emit(state.copyWith(status: AllChildProfileStatus.loading));

    final childDeviceProfiles =
        await _childDeviceRepository.deleteChildDeviceRemoteID(childId);
    emit(state.copyWith(
        status: AllChildProfileStatus.updateSuccess,
        profiles: childDeviceProfiles,
        message: "Successfully unpaired device"));
  }
}
