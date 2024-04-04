part of 'child_profile_cubit.dart';

enum ChildProfileStatus { loading, fetchSuccess, addSuccess, deleteSuccess, failure }


// Extension so that we can check status using if (state.status.isLoading) in the BlocBuilder/BlocListener
extension ChildProfileStatusX on ChildProfileStatus {
  bool get isLoading => this == ChildProfileStatus.loading;
  bool get isAddSuccess => this == ChildProfileStatus.addSuccess;
  bool get isDeleteSuccess => this == ChildProfileStatus.deleteSuccess;
  bool get isFailure => this == ChildProfileStatus.failure;
}

class ChildProfileState extends Equatable {
  final ChildProfileStatus status;
  final List<ChildModel> profiles;
  final String message;

  const ChildProfileState({
    this.status = ChildProfileStatus.loading,
    this.profiles = const <ChildModel>[],
    this.message = "",
  });

  ChildProfileState copyWith({
    ChildProfileStatus? status,
    List<ChildModel>? profiles,
    String? message,
  }) {
    return ChildProfileState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      message: message ?? "",
    );
  }

  @override
  List<Object?> get props => [status, profiles, message];
}
