part of 'analysis_result_bloc.dart';


sealed class AnalysisEvent {}

class AnalysisChangeChildEvent extends AnalysisEvent {
  final int childId;

  AnalysisChangeChildEvent({required this.childId});

}
class AnalysisLoadDataEvent extends AnalysisEvent {
  final int childId;

  AnalysisLoadDataEvent({required this.childId});

}


//TODO: need to change LoadDataEvent depending on fl_chart implementation
