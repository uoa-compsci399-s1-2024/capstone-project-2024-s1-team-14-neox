
class ChildData {
  final String timestamp;
  String childId;
  final int uv;
  final int light;
  final int accel_x;
  final int accel_y;
  final int accel_z;
  final int c;
  final int temp;

  ChildData({
    required this.timestamp,
    required this.childId,
    required this.uv,
    required this.light,
    required this.accel_x,
    required this.accel_y,
    required this.accel_z,
    required this.c,
    required this.temp,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      timestamp: json['tstamp'],
      childId: json['child_id'],
      uv: json['uv_index'],
      light: json['lux'],
      accel_x: json['accel_x'],
      accel_y: json['accel_y'],
      accel_z: json['accel_z'],
      c: json['c'],
      temp: json['temp'],
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


}