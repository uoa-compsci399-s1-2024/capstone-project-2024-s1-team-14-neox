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
}
