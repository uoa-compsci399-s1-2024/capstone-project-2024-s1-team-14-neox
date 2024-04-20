import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/domain/child_device_repository.dart';

part 'cloud_sync_state.dart';

class CloudSyncCubit extends Cubit<CloudSyncState> {
  CloudSyncCubit() : super(const CloudSyncState());

  Future<void> syncAllChildData() async {
    emit(state.copyWith(status: CloudSyncStatus.loading));
    try {
      await ChildDeviceRepository.syncAllChildData();
    } on Exception catch (e) {
      emit(state.copyWith(
        status: CloudSyncStatus.failure,
        message: e.toString(),
      ));
    }
    emit(state.copyWith(
      status: CloudSyncStatus.success,
      lastSynced: DateTime.now(),
    ));
  }
}
