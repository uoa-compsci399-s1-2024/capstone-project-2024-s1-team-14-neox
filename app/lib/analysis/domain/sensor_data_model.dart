import '../../data/entities/arduino_data_entity.dart';

class SensorDataModel {
  final DateTime dateTime;
  final int light;
  final int uv;
  final int accelX;
  final int accelY;
  final int accelZ;

  SensorDataModel(
    {required this.dateTime,
    required this.light,
    required this.uv,
    required this.accelX,
    required this.accelY,
    required this.accelZ,}
  );

  factory SensorDataModel.fromEntity(ArduinoDataEntity entity) =>
      SensorDataModel(
        dateTime: entity.datetime,
        light: entity.light ?? -100,
        uv: entity.uv ?? -200,
        accelX: entity.accel?[0] ?? -300,
        accelY:  entity.accel?[1] ?? -400,
        accelZ:  entity.accel?[2] ?? -500,
      );
  @override
  String toString() => "$dateTime, $light, $uv, $accelX, $accelY, $accelZ";
    
}
