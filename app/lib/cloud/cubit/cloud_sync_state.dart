part of 'cloud_sync_cubit.dart';

enum CloudSyncStatus {
  initial,
  loading,
  success,
  failure,
}

extension CloudSyncStatusX on CloudSyncStatus {
  bool get isInitial => this == CloudSyncStatus.initial;
  bool get isLoading => this == CloudSyncStatus.loading;
  bool get isSuccess => this == CloudSyncStatus.success;
  bool get isFailure => this == CloudSyncStatus.failure;
}

class CloudSyncState extends Equatable {
  const CloudSyncState({
    this.status = CloudSyncStatus.initial,
    this.progress,
    this.message,
  });

  final CloudSyncStatus status;
  final double? progress;
  final String? message;

  CloudSyncState copyWith({
    CloudSyncStatus? status,
    double? progress,
    String? message,
  }) {
    return CloudSyncState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        progress,
        message,
      ];
}