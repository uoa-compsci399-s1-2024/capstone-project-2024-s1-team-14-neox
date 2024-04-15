import 'dart:convert';
import 'package:capstone_project_2024_s1_team_14_neox/server/child_data.dart';
import 'package:http/http.dart' as http;

class ChildApiService {
  static const String apiUrl = 'https://m0q0u417k8.execute-api.ap-southeast-2.amazonaws.com/dev/samples';

  static Future<List<ChildData>> fetchChildrenData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => ChildData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch children data');
    }
  }

  static Future<ChildData> fetchChildDataById(int childId) async {

     List<ChildData> children = await fetchChildrenData();
     ChildData child = children.firstWhere((element) => element.childId == childId.toString());
     return child;

  }

  static Future<void> postData() async {
    List<ChildData> c = [
      ChildData("2024-02-01T12:30+12:00", "22", 2, 15),
      ChildData("2024-03-01T12:30+12:00", "22", 5, 30),
    ];

    final response = await http.post(
      Uri.parse("${apiUrl}/22"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // need to send a *list* of samples accessible under the property `samples` in the JSON
      body: jsonEncode({"samples": c}),
    );

    // NOTE: API doc has different status codes
    if (response.statusCode == 200) {
      print('Data posted successfully');
    } else {
      throw Exception('Failed to post data: (code ${response.statusCode}) ${response.body}');
    }
  }
}
