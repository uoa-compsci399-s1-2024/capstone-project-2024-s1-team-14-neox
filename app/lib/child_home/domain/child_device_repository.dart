import 'dart:math';
import 'dart:typed_data';
import 'package:capstone_project_2024_s1_team_14_neox/child_home/domain/child_device_model.dart';

import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/main.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/single_week_hourly_stats_model.dart';
import 'package:capstone_project_2024_s1_team_14_neox/statistics/domain/statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/entities/child_entity.dart';
import 'child_device_model.dart';

class ChildDeviceRepository {
  static const int bytesPerSample = 20;
  final SharedPreferences sharedPreferences;
  ChildDeviceRepository({required this.sharedPreferences});

  // Fetch all children profiles

  Future<List<ChildDeviceModel>> fetchChildProfiles() async {
    List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    List<ChildDeviceModel> models =
        entities.map((child) => ChildDeviceModel.fromEntity(child)).toList();

    StatisticsRepository statsRepo =
        StatisticsRepository(sharedPreferences: App.sharedPreferences);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    for (ChildDeviceModel model in models) {
      // SingleWeekHourlyStatsModel stats = (await repo.getListOfHourlyStats(today, 1, model.childId))[0];
      // model.outdoorTimeToday = stats.dailySum[today];
      // model.outdoorTimeWeek = stats.weeklyMean ~/ 7;

      // double monthTime = 0;
      // for (int i = 0; i < 4; i++) {
      //   monthTime += (await repo.getSingleWeekHourlyStats(today.subtract(Duration(days: 7 * (i + 1))), model.childId)).weeklyMean;
      // }
      // model.outdoorTimeMonth = monthTime ~/ 28;
      model.outdoorTimeToday =
          await statsRepo.getOutdoorTimeForPastDays(model.childId, 1);
      model.outdoorTimeWeek =
          (await statsRepo.getOutdoorTimeForPastDays(model.childId, 7)) ~/ 7;
      model.outdoorTimeMonth =
          (await statsRepo.getOutdoorTimeForPastDays(model.childId, 30)) ~/ 30;
    }

    return models;
  }

  // deletl child profile based on id

  // update child device remote id
  // add child remote id

  Future<List<ChildDeviceModel>> createChildProfile(
      String name, DateTime birthDate, String gender) async {
    int childId = await ChildEntity.saveSingleChildEntityFromParameters(
        name, birthDate, gender);
    await sharedPreferences.setInt("focus_id", childId);
    return await fetchChildProfiles();
  }

  Future<List<ChildDeviceModel>> deleteChildProfile(int deleteChildId) async {
    await ChildEntity.deleteChild(deleteChildId);
    List<ChildDeviceModel> childProfiles = await fetchChildProfiles();
    // Set focus child as first child
    if (childProfiles.isEmpty) {
      await sharedPreferences.remove("focus_id");
    } else {
      sharedPreferences.setInt("focus_id", childProfiles[0].childId);
    }
    return childProfiles;
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
    List<ArduinoDataEntity> data =
        await ChildEntity.getAllDataForChild(childId);
    if (data.isEmpty) {
      return 0;
    }
    return data
        .map((e) => e.datetime.millisecondsSinceEpoch ~/ 1000)
        .reduce(max);
  }

  Future<List<int>> parseAndSaveSamples(
      String childName, List<int> bytes, int childId) async {
        
    List<ArduinoDataEntity> samples = [];
    while (bytes.length % bytesPerSample != 0) {
      bytes.removeLast();
    }

    for (int i = 0; i < bytes.length;) {
      if (bytes.sublist(i, i + bytesPerSample).every((byte) => byte == 0)) {
        break;
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
      int calibratedLux = _calibrateLux(light);

      samples.add(ArduinoDataEntity(
        name: childName,
        childId: childId,
        uv: uv,
        light: calibratedLux,
        datetime: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        accel: Int16List.fromList([accelX, accelY, accelZ]),
        red: red,
        green: green,
        blue: blue,
        clear: clear,
        colourTemperature: colourTemperature,
        appClass: 0,
      ));
    }
    List<int> outdoorIndoorMins =
        await ArduinoDataEntity.saveListOfArduinoDataEntity(samples);

    debugPrint("Syncing: ${outdoorIndoorMins[0]} mins outdoors datetime");
    debugPrint("Syncing: ${outdoorIndoorMins[1]} mins indoors datetime");

    return outdoorIndoorMins;
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

  int _calibrateLux(int raw) {
    return (-2.290 +
            0.8646 * raw +
            -1.627 * pow(10, -5) * pow(raw, 2) +
            -4.515 * pow(10, -10) * pow(raw, 3))
        .toInt();
  }
}
