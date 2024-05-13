import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:equatable/equatable.dart';

part 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyRepository _studyRepository;

  StudyCubit(this._studyRepository) : super(const StudyState());

  // retrieveStudydetailsuisngcode id

  void fetchParticipatingStudies() {
    try {
      final List<StudyModel> studies =
          _studyRepository.fetchParticipatingStudies();

      emit(state.copyWith(status: StudyStatus.fetchSuccess, studies: studies));
    } on Exception catch (e) {
      emit(
        state.copyWith(
            status: StudyStatus.failure,
            message: "The child profiles cannot be fetched."),
      );
    }
  }

  void fetchNewStudy(String studyId) {
    emit(state.copyWith(status: StudyStatus.loading));
    StudyModel newStudy = _studyRepository.fetchNewStudy(studyId);

    emit(state.copyWith(
      status: StudyStatus.fetchSuccess,
      newStudy: newStudy,
    ));
  }

  // addchild

  void joinNewStudy(String studyId, List<String> childIds) {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = _studyRepository.joinNewStudy(studyId);

    emit(state.copyWith(
        status: StudyStatus.addStudySuccess,
        studies: studies,
        message: "You have successfully participated in the study"));
  }

  void addChildToStudy(String studyId, String childId) {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = _studyRepository.addChildToStudy(studyId);

    emit(state.copyWith(
        status: StudyStatus.addChildSuccess,
        studies: studies,
        message: "The child was successfully added to the study"));
  }

  void deleteChildFromStudy(String studyId, String childId) {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = _studyRepository.deleteChildFromStudy(studyId);

    emit(state.copyWith(
        status: StudyStatus.deleteChildSuccess,
        studies: studies,
        message: "The child was successfully added to the study"));
  }
  // deletechild
}
