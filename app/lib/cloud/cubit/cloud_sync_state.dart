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
    this.lastSynced,
  });

  final CloudSyncStatus status;
  final double? progress;
  final String? message;
  final DateTime? lastSynced;

  CloudSyncState copyWith({
    CloudSyncStatus? status,
    double? progress,
    String? message,
    DateTime? lastSynced,
  }) {
    return CloudSyncState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  @override
  List<Object?> get props => [
        status,
        progress,
        message,
        lastSynced,
      ];
}
