
class ChildData {
  final String timestamp;
  String childId;
  final int uv;
  final int light;

  ChildData({
    required this.timestamp,
    required this.childId,
    required this.uv,
    required this.light,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      timestamp: json['tstamp'],
      childId: json['child_id'],
      uv: json['uv_index'],
      light: json['lux'],
    );
  }

  Map<String, dynamic> toJson() {
    DateTime dateTime = DateTime.parse(timestamp);
    String iso8601Timestamp = '${dateTime.toUtc().toIso8601String().substring(0, 19)}Z';

    return {
      'timestamp': iso8601Timestamp,
      'child_id': childId,
      'uv': uv,
      'light': light,
    };
  }






  static List<ChildData> getChildDataList(String id) {
    List<ChildData> childDataList = [
      ChildData(
        timestamp: '2024-04-21T08:00:00',
        childId: id,
        uv: 5,
        light: 100,
      ),
      ChildData(
        timestamp: '2024-04-21T08:15:00',
        childId: id,
        uv: 6,
        light: 110,
      ),
      ChildData(
        timestamp: '2024-04-21T08:30:00',
        childId: id,
        uv: 4,
        light: 90,
      ),

    ];

    return childDataList;
  }
}