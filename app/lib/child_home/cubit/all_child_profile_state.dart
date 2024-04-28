part of 'all_child_profile_cubit.dart';

enum AllChildProfileStatus {
  loading,
  fetchSuccess,
  addSuccess,
  deleteSuccess,
  updateSuccess,
  failure
}

// Extension so that we can check status using if (state.status.isLoading) in the BlocBuilder/BlocListener
extension AllChildProfileStatusX on AllChildProfileStatus {
  bool get isLoading => this == AllChildProfileStatus.loading;
  bool get isAddSuccess => this == AllChildProfileStatus.addSuccess;
  bool get isUpdateSuccess => this == AllChildProfileStatus.updateSuccess;
  bool get isDeleteSuccess => this == AllChildProfileStatus.deleteSuccess;
  bool get isFailure => this == AllChildProfileStatus.failure;
}

class AllChildProfileState extends Equatable {
  final AllChildProfileStatus status;
  final List<ChildDeviceModel> profiles;
  final String message;

  const AllChildProfileState({
    this.status = AllChildProfileStatus.loading,
    this.profiles = const <ChildDeviceModel>[],
    this.message = "",
  });

  AllChildProfileState copyWith({
    AllChildProfileStatus? status,
    List<ChildDeviceModel>? profiles,
    String? message,
  }) {
    return AllChildProfileState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      message: message ?? "",
    );
  }

  @override
  List<Object?> get props => [status, ...profiles, message];
}
