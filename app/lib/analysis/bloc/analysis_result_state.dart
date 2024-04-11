part of 'analysis_result_bloc.dart';

enum AnalysisStatus {
  initial,
  loading,
  success,
  failure,
}

extension AnalysisStatusX on AnalysisStatus {
  bool get isLoading => this == AnalysisStatus.loading;
  bool get isInitial => this == AnalysisStatus.initial;
  bool get isSuccess => this == AnalysisStatus.success;
  bool get isFailure => this == AnalysisStatus.failure;
}

class AnalysisState extends Equatable {
  final AnalysisStatus status;
  final int focusChildId;
  // TODO: only need list of int to represent how much time was spend outdoors
  // Might need three lists to represent day, week, month
  final List<SensorDataModel> data;

  const AnalysisState({
    this.status = AnalysisStatus.initial,
    this.focusChildId = -1,
    this.data = const <SensorDataModel>[],
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    int? focusChildId,
    List<SensorDataModel>? data,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      focusChildId: focusChildId ?? this.focusChildId,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
      ];
}
