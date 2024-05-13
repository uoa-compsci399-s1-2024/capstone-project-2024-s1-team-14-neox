import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:equatable/equatable.dart';

part 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyRepository _studyRepository;

  StudyCubit(this._studyRepository) : super(StudyState());

  // retrieveStudydetailsuisngcode id

  void fetchAllParticipatingStudies() async {
    try {
      final List<StudyModel> studies = await 
          _studyRepository.fetchAllParticipatingStudies();

      emit(state.copyWith(status: StudyStatus.fetchSuccess, studies: studies));
    } on Exception catch (e) {
      emit(
        state.copyWith(
            status: StudyStatus.failure,
            message: "The child profiles cannot be fetched."),
      );
    }
  }

  void fetchStudyFromServer(String studyId) {
    emit(state.copyWith(status: StudyStatus.loading));
    StudyModel newStudy = _studyRepository.fetchStudyFromServer(studyId);

    emit(state.copyWith(
      status: StudyStatus.fetchSuccess,
      newStudy: newStudy,
    ));
  }

  // addchild

  void joinNewStudy(StudyModel study, List<int> childIds) async {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = await _studyRepository.joinNewStudy(study, childIds);

    emit(state.copyWith(
        status: StudyStatus.addStudySuccess,
        studies: studies,
        message: "You have successfully participated in the study"));
  }

  void addChildToStudy(int childId, String studyCode) async {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = await _studyRepository.addChildToStudy(childId, studyCode);

    emit(state.copyWith(
        status: StudyStatus.addChildSuccess,
        studies: studies,
        message: "The child was successfully added to the study"));
  }

  void deleteChildFromStudy(int childId, String studyCode) async {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = await _studyRepository.deleteChildFromStudy(childId, studyCode);

    emit(state.copyWith(
        status: StudyStatus.deleteChildSuccess,
        studies: studies,
        message: "The child was successfully added to the study"));
  }
  // deletechild
}
