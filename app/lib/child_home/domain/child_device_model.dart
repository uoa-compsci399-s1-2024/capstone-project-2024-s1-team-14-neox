import '../../data/entities/child_entity.dart';

class ChildDeviceModel {
  final int? id;
  final String name;
  final DateTime birthDate;
  String? deviceRemoteId;
  String? authorisationCode;
  DateTime? lastSynced;

  ChildDeviceModel(
      {required this.id,
      required this.name,
      required this.birthDate,
      this.deviceRemoteId,
      this.authorisationCode,
      this.lastSynced});

  factory ChildDeviceModel.fromEntity(ChildEntity entity) => ChildDeviceModel(
        id: entity.id,
        name: entity.name,
        birthDate: entity.birthDate,
        deviceRemoteId: entity.arduinoDeviceEntity?.remoteDeviceId,
        authorisationCode: entity.arduinoDeviceEntity?.authorisationCode,
        // TODO implement last synced in database
      );

  @override
  String toString() => "$id, $name, $birthDate, $deviceRemoteId";

//  factory MobileViewModel.fromJson(final Map<String, dynamic> json) =>
//       MobileViewModel(
//         countryCallingCode: json['countryCallingCode'],
//         mobileNumber: json['mobileNumber'],
//       );
}
