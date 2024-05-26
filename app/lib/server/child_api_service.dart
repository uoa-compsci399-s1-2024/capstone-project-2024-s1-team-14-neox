import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_data.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ChildApiService {
  static const String apiUrl =
      'https://xu31tcdj0e.execute-api.ap-southeast-2.amazonaws.com/dev';

  static void fetchChildrenData() async {
    Dio dio = Dio();
    try {
      var response = await dio.get('$apiUrl/samples');
      var dataList = [];

      for(final data in response.data){

        var sample = ChildData.fromJson(data);
        dataList.add(sample);

      }
      
    } catch (e) {
      print(e);
    }
  }



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

  static getStudy(String idCode) async{

    Dio dio = Dio();

    final token = await AWSServices().getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final String url = '$apiUrl/studies/$idCode/info';
    try {
      var response = await dio.get(url, options: Options(headers: defaultHeaders));
      print(response.data);
    } catch (e) {
      print('Error making GET request: $e');
    }
  }


  static addChildToStudy(String serverId) async {
    ;
  }


}

