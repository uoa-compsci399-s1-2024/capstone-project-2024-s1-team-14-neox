import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class ChildModel {
  final String name;
  final DateTime dateOfBirth;
  String? deviceRemoteId;

  ChildModel(this.name, this.dateOfBirth, this.deviceRemoteId);
  @override
  String toString() => "$name, $dateOfBirth, $deviceRemoteId";

  void updateDeviceRemoteId(String? deviceRemoteId) {
    this.deviceRemoteId = deviceRemoteId;
  }
  
}