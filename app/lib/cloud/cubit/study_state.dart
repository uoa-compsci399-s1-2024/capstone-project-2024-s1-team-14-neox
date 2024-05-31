part of 'study_cubit.dart';

enum StudyStatus {
  loading,
  fetchSuccess,
  fetchStudySuccess,
  addStudySuccess,
  addChildSuccess,
  deleteStudySuccess,
  deleteChildSuccess,
  failure,
}

// Extension so that we can check status using if (state.status.isLoading) in the BlocBuilder/BlocListener
extension StudyStatusX on StudyStatus {
  bool get isLoading => this == StudyStatus.loading;
  bool get isFetchSuccess => this == StudyStatus.fetchSuccess;
  bool get isFetchStudySuccess => this == StudyStatus.fetchStudySuccess;
  bool get isAddStudySuccess => this == StudyStatus.addStudySuccess;
  bool get isAddChildSuccess => this == StudyStatus.addChildSuccess;
  bool get isDeleteStudySuccess => this == StudyStatus.deleteStudySuccess;
  bool get isDeleteChildSuccess => this == StudyStatus.deleteChildSuccess;
  bool get isFailure => this == StudyStatus.failure;
}

class StudyState extends Equatable {
  final StudyStatus status;
  final List<StudyModel> studies;
  final String message;
  final StudyModel? newStudy;

  const StudyState({
    this.status = StudyStatus.loading,
    this.studies = const <StudyModel>[],
    this.message = "",
    this.newStudy,
  });

  StudyState copyWith({
    StudyStatus? status,
    List<StudyModel>? studies,
    String? message,
    StudyModel? newStudy,
  }) {
    return StudyState(
      status: status ?? this.status,
      studies: studies ?? this.studies,
      message: message ?? "",
      newStudy: newStudy,
    );
  }

  @override
  List<Object> get props => [status, studies, message];
}
