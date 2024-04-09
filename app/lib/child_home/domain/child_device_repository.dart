import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';

import '../../analysis/domain/sensor_data_model.dart';
import '../../data/entities/child_entity.dart';
import 'child_device_model.dart';

class ChildDeviceRepository {
  // Replaces database

  static int childId = 0;
  static List<ChildDeviceModel> _dummyChildDeviceDatabase = [];
  static Map<int, List<SensorDataModel>> _dummyArduinoDatabase = {};

  // Fetch all children profiles

  Future<List<ChildDeviceModel>> fetchChildProfiles() async {
    // List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    // return entities.map((child) => ChildDeviceModel.fromEntity(child)).toList();
    return _dummyChildDeviceDatabase;
  }

  // deletl child profile based on id

  // update child device remote id
  // add child remote id

  Future<List<ChildDeviceModel>> createChildProfile(
      String name, DateTime birthDate) async {
    // ChildEntity.saveSingleChildEntityFromParameters(name, birthDate);
    _dummyChildDeviceDatabase.add(ChildDeviceModel(
        childId: childId++, childName: name, birthDate: birthDate));
    _dummyArduinoDatabase[childId] = [];
    return fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> deleteChildProfile(int childId) async {
    // ChildEntity.deleteChild(childId);
    _dummyChildDeviceDatabase
        .removeWhere((element) => element.childId == childId);
    return fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> updateChildDeviceRemoteID(
      int? childId, String deviceRemoteId) async {
    // ChildEntity.updateRemoteDeviceId(childId, deviceRemoteId);
    _dummyChildDeviceDatabase[_dummyChildDeviceDatabase
            .indexWhere((element) => element.childId == childId)]
        .deviceRemoteId = deviceRemoteId;
    return fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> deleteChildDeviceRemoteID(int? childId) async {
    // ChildEntity.deleteDeviceForChild(childId);
    _dummyChildDeviceDatabase[_dummyChildDeviceDatabase
            .indexWhere((element) => element.childId == childId)]
        .deviceRemoteId = null;
    return fetchChildProfiles();
  }

  static Future<void> parseAndSaveSamples(
      String childName, List<int> bytes, int childId) async {
    const int bytesPerSample = 14;
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

      // await ArduinoDataEntity.saveSingleArduinoDataEntity(
      //   ArduinoDataEntity(
      //     name: childName,
      //     uv: uv,
      //     light: light,
      //     datetime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      //     accel: Int16List.fromList([accelX, accelY, accelZ]),
      //   ),
      // );

      _dummyArduinoDatabase[childId]?.add(
        SensorDataModel(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          light: light,
          uv: uv,
          accelX: accelX,
          accelY: accelY,
          accelZ: accelZ,
        ),
      );
    }
  }

  static List<SensorDataModel>? fetchArduinoSamplesByChildId(
      int childId) {
    // List<ArduinoDataEntity> entities =
    //     await ChildEntity.getAllDataForChild(childId);
    return _dummyArduinoDatabase[childId];
  }
  // static Future<List<SensorDataModel>> fetchArduinoSamplesByChildId(
  //     int childId) async {
  //   List<ArduinoDataEntity> entities =
  //       await ChildEntity.getAllDataForChild(childId);
  //   return entities.map((data) => SensorDataModel.fromEntity(data)).toList();
  // }
}
