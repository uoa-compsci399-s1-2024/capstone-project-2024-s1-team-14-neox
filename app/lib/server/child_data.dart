
class ChildData {
  final String tstamp;
  final String childId;
  final int uvIndex;
  final int lux;

  ChildData({
    required this.tstamp,
    required this.childId,
    required this.uvIndex,
    required this.lux,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      tstamp: json['tstamp'],
      childId: json['child_id'],
      uvIndex: json['uv_index'],
      lux: json['lux'],
    );
  }

  Map<String, dynamic> toJson() {
    DateTime dateTime = DateTime.parse(tstamp);
    String iso8601Timestamp = '${dateTime.toUtc().toIso8601String().substring(0, 19)}Z';

    return {
      'timestamp': iso8601Timestamp,
      'child_id': childId,
      'uv': uvIndex,
      'light': lux,
    };
  }





  static List<ChildData> getChildDataList() {
    List<ChildData> childDataList = [
      ChildData(
        tstamp: '2024-04-21T08:00:00',
        childId: '22',
        uvIndex: 5,
        lux: 100,
      ),
      ChildData(
        tstamp: '2024-04-21T08:15:00',
        childId: '22',
        uvIndex: 6,
        lux: 110,
      ),
      ChildData(
        tstamp: '2024-04-21T08:30:00',
        childId: '22',
        uvIndex: 4,
        lux: 90,
      ),

    ];

    return childDataList;
  }
}





