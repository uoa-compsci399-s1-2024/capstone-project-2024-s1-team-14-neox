import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:equatable/equatable.dart';

part 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyRepository _studyRepository;

  StudyCubit(this._studyRepository) : super(StudyState());

  // retrieveStudydetailsuisngcode id

  void getAllParticipatingStudies() async {
    try {
      final List<StudyModel> studies = await 
          _studyRepository.getAllParticipatingStudies();

      emit(state.copyWith(status: StudyStatus.fetchSuccess, studies: studies));
    } on Exception catch (e) {
      emit(
        state.copyWith(
            status: StudyStatus.failure,
            message: e.toString()),
      );
    }
  }

  

  Future<void> fetchStudyFromServer(String studyId) async {
    emit(state.copyWith(status: StudyStatus.loading));
    StudyModel? newStudy = await _studyRepository.fetchStudyFromServer(studyId);
    if (newStudy == null) {
      emit(state.copyWith(
          status: StudyStatus.failure,
          message: "Study not found"));
      return;
    }

    emit(state.copyWith(
      status: StudyStatus.fetchStudySuccess,
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
  void withdrawStudy(String studyCode) async {
    emit(state.copyWith(status: StudyStatus.loading));

    List<StudyModel> studies = await _studyRepository.deleteStudy(studyCode);

    emit(state.copyWith(
        status: StudyStatus.deleteStudySuccess,
        studies: studies,
        message: "You have successfully opted out from the study"));
  }

  
  void testCubit() {
    print("test" + DateTime.now().toString());
  }
  // deletechild
}
