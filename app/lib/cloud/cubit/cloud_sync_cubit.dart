import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../child_home/domain/child_device_repository.dart';

part 'cloud_sync_state.dart';

class CloudSyncCubit extends Cubit<CloudSyncState> {
  CloudSyncCubit() : super(const CloudSyncState());

  Future<void> uploadAllChildData() async {
    emit(state.copyWith(status: CloudSyncStatus.loading));

    await ChildEntity.uploadAllChildData().then(
      (value) async {
        await ChildEntity.downloadAllChildData();
        emit(state.copyWith(status: CloudSyncStatus.success));
        return value;
      },
    );
  }

  Future<void> retrieveChildrenNotInDB() async {
    print("entered retrieveing children");

    await ChildEntity.retrieveChildrenInServer();
    print("done with retrieveing children");
  }
}
