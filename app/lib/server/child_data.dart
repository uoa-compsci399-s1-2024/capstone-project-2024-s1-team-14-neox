
class ChildData {
  final String timestamp;
  String childId;
  final int uv;
  final int light;
  final int accel_x;
  final int accel_y;
  final int accel_z;
  final int clear;
  final int colourTemperature;
  final int green;
  final int blue;
  final int red;

  ChildData({
    required this.timestamp,
    required this.childId,
    required this.uv,
    required this.light,
    required this.accel_x,
    required this.accel_y,
    required this.accel_z,
    required this.clear,
    required this.colourTemperature,
    required this.green,
    required this.red,
    required this.blue,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      timestamp: json['tstamp'],
      childId: json['child_id'],
      uv: json['uv'],
      light: json['light'],
      accel_x: json['accel_x'],
      accel_y: json['accel_y'],
      accel_z: json['accel_z'],
      clear: json['col_clear'],
      colourTemperature: json['col_temp'],
      red: json['col_red'],
      green: json['col_green'],
      blue: json['col_blue'],
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
      'accel_x': accel_x,
      'accel_y': accel_y,
      'accel_z': accel_z,
      'col_clear': clear,
      'col_temp': colourTemperature,
      'col_red': red,
      'col_green': green,
      'col_blue': blue,
    };
  }


}