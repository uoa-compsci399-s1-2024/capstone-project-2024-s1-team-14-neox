import 'package:capstone_project_2024_s1_team_14_neox/data/entities/arduino_data_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/data/entities/child_entity.dart';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_data.dart';
import 'package:dio/dio.dart';

class ChildApiService {
  static const String apiUrl =
      'https://e4h0hpg8k5.execute-api.ap-southeast-2.amazonaws.com/dev/samples';

  static void fetchChildrenData() async {
    Dio dio = Dio();
    try {
      var response = await dio.get(apiUrl);
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

    for (var sample in sampleList) {
      ChildData newSample = sample.toChildData();
      dataList.add(newSample);
    }
    final url = '$apiUrl/$childId';
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
}
