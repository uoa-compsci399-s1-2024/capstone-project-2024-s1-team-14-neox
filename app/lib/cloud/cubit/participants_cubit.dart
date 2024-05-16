import 'package:bloc/bloc.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/domain/study_repository.dart';
import 'package:equatable/equatable.dart';

import '../domain/participating_child_model.dart';

part 'participants_state.dart';

class ParticipantsCubit extends Cubit<ParticipantsState> {
  final StudyRepository _studyRepository;
  ParticipantsCubit(this._studyRepository) : super(ParticipantsState());

  void getAllChildren() async {
    emit(state.copyWith(status: ParticipantsStatus.loading));
    List<ParticipatingChildModel> allChildren = [];
    try {
      allChildren = await _studyRepository.getAllChildren();
    } on Exception catch (e) {
      emit(
        state.copyWith(
            status: ParticipantsStatus.failure, message: e.toString()),
      );
    }
    emit(
      ParticipantsState(
        status: ParticipantsStatus.success,
        allChildren: allChildren,
        notParticipating: allChildren,
      ),
    );
  }

  void getParticipatingStatus(String studyCode) async {
    emit(state.copyWith(status: ParticipantsStatus.loading));
    List<ParticipatingChildModel> allChildren = [];
    List<ParticipatingChildModel> participating = [];
    List<ParticipatingChildModel> notParticipating = [];

    try {
      allChildren = await _studyRepository.getAllChildren();
      participating = await _studyRepository.getChildrenByStudyCode(studyCode);
    } on Exception catch (e) {
      emit(
        state.copyWith(
            status: ParticipantsStatus.failure, message: e.toString()),
      );
    }

    notParticipating.addAll(allChildren.where(
        (c1) => participating.every((c2) => c1.childId != c2.childId)));

    emit(
      state.copyWith(
        status: ParticipantsStatus.success,
        allChildren: allChildren,
        participating: participating,
        notParticipating: notParticipating,
      ),
    );
  }

  void addChildToStudy(int childId, String studyCode) async {
    emit(state.copyWith(status: ParticipantsStatus.loading));

    await _studyRepository.addChildToStudy(childId, studyCode);

    getParticipatingStatus(studyCode);
  }

  void deleteChildFromStudy(int childId, String studyCode) async {
    emit(state.copyWith(status: ParticipantsStatus.loading));

    await _studyRepository.deleteChildFromStudy(childId, studyCode);

    getParticipatingStatus(studyCode);
    //TODO error handling
  }

  void testParticipantsCubit() {
    print("testing participants" + DateTime.now().toString());
  }
}
