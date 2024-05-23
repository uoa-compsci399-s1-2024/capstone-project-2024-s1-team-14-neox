import 'dart:math';
import 'dart:typed_data';

import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/classifiers/xgboost.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:flutter/material.dart';

import '../../data/entities/child_entity.dart';
import 'child_device_model.dart';
import 'classifiers/xgboost.dart';

class ChildDeviceRepository {
  static const int bytesPerSample = 20;

  // Fetch all children profiles

  Future<List<ChildDeviceModel>> fetchChildProfiles() async {
    List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    List<ChildDeviceModel> models = entities.map((child) => ChildDeviceModel.fromEntity(child)).toList();
    
    Random rng = Random();
    for (ChildDeviceModel model in models) {
      model.outdoorTimeToday = rng.nextInt(200);
      model.outdoorTimeWeek = rng.nextInt(200);
      model.outdoorTimeMonth = rng.nextInt(200);
    }
    
    return models;
  }

  // deletl child profile based on id

  // update child device remote id
  // add child remote id

  Future<List<ChildDeviceModel>> createChildProfile(
      String name, DateTime birthDate, String gender) async {
    await ChildEntity.saveSingleChildEntityFromParameters(
        name, birthDate, gender);

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

  Future<int> getMostRecentSampleTimestamp(int childId) async {
    List<ArduinoDataEntity> data = await ChildEntity.getAllDataForChild(childId);
    if (data.isEmpty) {
      return 0;
    }
    return data.map((e) => e.datetime.millisecondsSinceEpoch ~/ 1000).reduce(max);
  }

  Future<void> parseAndSaveSamples(
      String childName, List<int> bytes, int childId) async {
    List<ArduinoDataEntity> samples = [];
    while (bytes.length % bytesPerSample != 0) {
      bytes.removeLast();
    }

    for (int i = 0; i < bytes.length;) {
      if (bytes.sublist(i, i + bytesPerSample).every((byte) => byte == 0)) {
        return;
      }

      int readUint16() {
        int value = bytes[i] | (bytes[i + 1] << 8);
        i += 2;
        return value;
      }

      int timestamp = bytes[i] |
          (bytes[i + 1] << 8) |
          (bytes[i + 2] << 16) |
          (bytes[i + 3] << 24);
      i += 4;
      int uv = readUint16();
      int accelX = readUint16(); // Although values are unsigned here,
      int accelY = readUint16(); // acceleration is converted to signed
      int accelZ = readUint16(); // in Int16List.fromList.
      int red = readUint16();
      int green = readUint16();
      int blue = readUint16();
      int clear = readUint16();
      int light = _calculateLux(red, blue, green);
      int colourTemperature =
          _calculateColourTemperature(red, blue, green, clear);

      int appClass =
          score([uv, light, accelX, accelY, accelZ])[1] > 0.7 ? 1 : 0;

      samples.add(ArduinoDataEntity(
        name: childName,
        childId: childId,
        uv: uv,
        light: light,
        datetime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        accel: Int16List.fromList([accelX, accelY, accelZ]),
        red: red,
        green: green,
        blue: blue,
        clear: clear,
        colourTemperature: colourTemperature,
        appClass: appClass,
      ));
    }
    await ArduinoDataEntity.saveListOfArduinoDataEntity(samples);
  }

  int _calculateLux(int r, int g, int b) {
    return ((-0.32466 * r) + (1.57837 * g) + (-0.73191 * b))
        .toInt()
        .clamp(0, 0xFFFF);
  }

  int _calculateColourTemperature(int r, int g, int b, int c) {
    const int integrationTime = 101;

    if (c == 0) {
      return 0;
    }

    int sat;
    if ((256 - integrationTime) > 63) {
      sat = 65535;
    } else {
      sat = 1024 * (256 - integrationTime);
    }
    if ((256 - integrationTime) <= 63) {
      sat -= sat ~/ 4;
    }
    if (c >= sat) {
      return 0;
    }

    int ir = (r + g + b > c) ? (r + g + b - c) ~/ 2 : 0;
    int r2 = r - ir;
    int b2 = b - ir;
    if (r2 == 0) {
      return 0;
    }

    return ((3810 * b2) ~/ r2 + 1391).clamp(0, 0xFFFF);
  }

}
