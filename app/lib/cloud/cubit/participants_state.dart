part of 'participants_cubit.dart';

enum ParticipantsStatus {
  loading,
  success,
  failure,
}

extension ParticipantsStatusX on ParticipantsStatus {
  bool get isLoading => this == ParticipantsStatus.loading;
  bool get isSuccess => this == ParticipantsStatus.success;

  bool get isFailure => this == ParticipantsStatus.failure;
}

class ParticipantsState extends Equatable {
  final ParticipantsStatus status;
  final List<ParticipatingChildModel> participating;
  final List<ParticipatingChildModel> notParticipating;
  final String message;

  const ParticipantsState({
    this.status = ParticipantsStatus.loading,
    this.participating = const <ParticipatingChildModel>[],
    this.notParticipating = const <ParticipatingChildModel>[],
    this.message = "",
  });

  ParticipantsState copyWith({
    ParticipantsStatus? status,
    List<ParticipatingChildModel>? participating,
    List<ParticipatingChildModel>? notParticipating,
    String? message,
  }) {
    return ParticipantsState(
      status: status ?? this.status,
      participating: participating ?? this.participating,
      notParticipating: notParticipating ?? this.notParticipating,
      message: message ?? "",
    );
  }

  @override
  List<Object> get props => [status, participating, notParticipating];
}
