import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';

import '../../data/entities/child_entity.dart';
import 'child_device_model.dart';
import 'classifiers/xgboost.dart';

class ChildDeviceRepository {
  static const int bytesPerSample = 14;

  // Fetch all children profiles

  Future<List<ChildDeviceModel>> fetchChildProfiles() async {
    List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    return entities.map((child) => ChildDeviceModel.fromEntity(child)).toList();
  }

  // deletl child profile based on id

  // update child device remote id
  // add child remote id

  Future<List<ChildDeviceModel>> createChildProfile(
      String name, DateTime birthDate, String gender) async {
    await ChildEntity.saveSingleChildEntityFromParameters(name, birthDate, gender);

    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> deleteChildProfile(int childId) async {
    await ChildEntity.deleteChild(childId);
    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> updateChildDeviceRemoteID(
      int childId, String deviceRemoteId) async {
    await ChildEntity.updateRemoteDeviceId(childId, deviceRemoteId);
    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> updateChildAuthenticationCode(
      int childId, String authorisationCode) async {
    await ChildEntity.updateAuthorisationCode(childId, authorisationCode);
    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> updateChildDetails(
    int childId,
    String name,
    DateTime birthDate,
    String gender,
    String authorisationCode,
  ) async {
    await ChildEntity.updateChildDetails(
      childId,
      name,
      birthDate,
      gender,
      authorisationCode,
    );
    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> deleteChildDeviceRemoteID(int childId) async {
    await ChildEntity.deleteDeviceForChild(childId);
    return await fetchChildProfiles();
  }

  Future<void> parseAndSaveSamples(
      String childName, List<int> bytes, int childId) async {
    while (bytes.length % bytesPerSample != 0) {
      bytes.removeLast();
    }

    for (int i = 0; i < bytes.length;) {
      if (bytes.sublist(i, i + bytesPerSample).every((byte) => byte == 0)) {
        return;
      }

      int timestamp = bytes[i] |
          (bytes[i + 1] << 8) |
          (bytes[i + 2] << 16) |
          (bytes[i + 3] << 24);
      i += 4;
      int uv = bytes[i] | (bytes[i + 1] << 8);
      i += 2;
      int light = bytes[i] | (bytes[i + 1] << 8);
      i += 2;
      int accelX = bytes[i] | (bytes[i + 1] << 8);
      i += 2;
      int accelY = bytes[i] | (bytes[i + 1] << 8);
      i += 2;
      int accelZ = bytes[i] | (bytes[i + 1] << 8);
      i += 2;

      int appClass = score([uv, light, accelX, accelY, accelZ])[1] > 0.7 ? 1 : 0;



      await ArduinoDataEntity.saveSingleArduinoDataEntity(
        ArduinoDataEntity(
          name: childName,
          childId: childId,
          uv: uv,
          light: light,
          datetime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          accel: Int16List.fromList([accelX, accelY, accelZ]),
          appClass: appClass,

        ),
      );
    }
  }


  //////////////////////////////////
  ///           CLOUD            ///
  //////////////////////////////////

  static Future<void> syncAllChildData() async {
    await ChildEntity.syncAllChildData();
  }
}
