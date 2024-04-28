import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_data.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ChildApiService {
  static const String apiUrl =
      'https://xql8m9zukd.execute-api.ap-southeast-2.amazonaws.com/dev';

  static void fetchChildrenData() async {
    Dio dio = Dio();
    try {
      var response = await dio.get('$apiUrl/samples');
      print(response);
    } catch (e) {
      print(e);
    }
  }

  //
  // static Future<ChildData> fetchChildDataById(int childId) async {
  //
  //    List<ChildData> children = await fetchChildrenData();
  //    ChildData child = children.firstWhere((element) => element.childId == childId.toString());
  //    return child;
  //
  // }

  static Future<void> postData(int childId) async {
    Dio dio = Dio();
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
      List<Map<String, dynamic>> jsonSamples = [];

      for (var childData in dataList) {
        final jsonData = childData.toJson();
        jsonSamples.add(jsonData);
      }
      final data = {"samples": jsonSamples};
      final response = await dio.post(url, data: data);
      print(response.statusCode);
      print(response.data);
    } catch (e) {
      print('Error posting data: $e');
    }
  }

  static Future<String> registerChild() async {
    print('Register success');
    Dio dio = Dio();
    const url = '$apiUrl/children';
    var response = await dio.post(url);

    print(response.data);
    Map<String, dynamic> responseData = response.data;
    String id = responseData['data']['id'];
    return id;
  }


}

