import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/childStudy_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/study_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_data.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ChildApiService {
  static const String apiUrl =
      'https://xu31tcdj0e.execute-api.ap-southeast-2.amazonaws.com/dev';

  static  Future<Map<String, dynamic>> initializeHeader() async{
    final token = await AWSServices().getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return defaultHeaders;
  }


  static void fetchChildrenData(int childId) async {
    ChildEntity? child = await ChildEntity.queryChildById(childId);
    String? serverId = child?.serverId;


    final defaultHeaders = await initializeHeader();
    Dio dio = Dio();
    try {
      var response = await dio.get('$apiUrl/samples/$serverId',
          options: Options(headers: defaultHeaders));
      List<ArduinoDataEntity> dataList = [];

      for (final data in response.data["data"]) {
        ChildData sample = ChildData.fromJson(data);
        ArduinoDataEntity arduinoDataEntity = sample.toArduinoData(childId);
        dataList.add(arduinoDataEntity);
      }
      ArduinoDataEntity.saveListOfArduinoDataEntity(dataList);
      print("samples retrieved");
    } catch (e) {
      print(e);
    }
  }

  static Future<void> postData(int childId) async {
    Dio dio = Dio();

    final defaultHeaders = await initializeHeader();

    var sampleList = await ArduinoDataEntity.queryArduinoDataById(childId);
    var dataList = [];
    ChildEntity? child = await ChildEntity.queryChildById(childId);
    String? serverId = child?.serverId;

    for (var sample in sampleList) {
      ChildData newSample = sample.toChildData(serverId!);
      dataList.add(newSample);
    }

    final url = '$apiUrl/samples/$serverId';

    try {

      int chunkSize = 1000;

      for (int i = 0; i < dataList.length; i += chunkSize) {
        List chunk = dataList.sublist(
          i,
          i + chunkSize > dataList.length ? dataList.length : i + chunkSize,
        );

        List jsonSamples = chunk.map((childData) => childData.toJson()).toList();

        final data = {"samples": jsonSamples};


        await dio.post(
          url,
          options: Options(headers: defaultHeaders),
          data: data,
        );
      }
    } catch (e) {
      print('Error posting data: $e');
    }
  }

  static Future<String> registerChild() async {
    print('Register success');
    Dio dio = Dio();
    final defaultHeaders = await initializeHeader();

    const url = '$apiUrl/children';
    var response =
        await dio.post(url, options: Options(headers: defaultHeaders));

    Map<String, dynamic> responseData = response.data;
    String id = responseData['data']['id'];
    return id;
  }

  static Future<StudyEntity?> getStudy(String studyCode) async {
    Dio dio = Dio();

    final defaultHeaders = await initializeHeader();

    final String url = '$apiUrl/studies/$studyCode/info';
    try {
      var response =
          await dio.get(url, options: Options(headers: defaultHeaders));
      Map<String, dynamic> data = response.data["data"];

      if (data["description"] == null) {
        data["description"] = "TBC";
      }
      if (data["name"] == null) {
        data["name"] = 'TBC';
      }
      StudyEntity study = StudyEntity.fromJson(data, studyCode);
      StudyEntity.createStudy(study);
      return study;
    } catch (e) {
      print('$e');
      return null;
    }
  }

  static addChildToStudy(int childId, String studyCode) async {
    ChildStudyAssociationsEntity.saveSingleChildStudy(childId, studyCode);
    ChildEntity? child = await ChildEntity.queryChildById(childId);
    String? serverId;

    if (child?.serverId == '') {
      String serverId = await ChildApiService.registerChild();
      await ChildEntity.updateServerId(childId, serverId);
    }

    serverId = child?.serverId;

    Dio dio = Dio();
    String url = '$apiUrl/children/$serverId/studies/$studyCode';

    final defaultHeaders = await initializeHeader();

    try {
      var response =
          await dio.put(url, options: Options(headers: defaultHeaders));
      print(response.statusCode);
    } catch (e) {
      print('$e');
    }
  }

  static removeChildFromStudy(int childId, String studyCode) async {
    ChildStudyAssociationsEntity.removeFromStudy(childId, studyCode);
    ChildEntity? child = await ChildEntity.queryChildById(childId);
    String? serverId = child?.serverId;

    Dio dio = Dio();
    String url = '$apiUrl/children/$serverId/studies/$studyCode';

    final defaultHeaders = await initializeHeader();

    try {
      var response =
          await dio.delete(url, options: Options(headers: defaultHeaders));
      print(response.statusCode);
    } catch (e) {
      print('$e');
    }
  }

  // static getAllStudies() async {
  //   StudyEntity.clearStudyTable();
  //   final defaultHeaders = await initializeHeader();
  //
  //   Dio dio = Dio();
  //
  //   String url = '$apiUrl/studies';
  //   var response =
  //       await dio.get(url, options: Options(headers: defaultHeaders));
  //   print(response.data);
  //   var listOfStudies = response.data["data"];
  //
  //   for (final studyCode in listOfStudies) {
  //     await ChildApiService.getStudy(studyCode["id"]);
  //   }
  // }
}
