import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class ChildModel {
  final String name;
  final DateTime dateOfBirth;
  final BluetoothDevice? device;

  ChildModel(this.name, this.dateOfBirth, this.device);

  
}