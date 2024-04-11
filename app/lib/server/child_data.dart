
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
}





