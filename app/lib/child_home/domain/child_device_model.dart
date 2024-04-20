import '../../data/entities/child_entity.dart';

class ChildDeviceModel {
  final int childId;
  final String childName;
  final DateTime birthDate;
  String? deviceRemoteId;
  String? authorisationCode;
  DateTime? lastSynced;

  ChildDeviceModel(
      {required this.childId,
      required this.childName,
      required this.birthDate,
      this.deviceRemoteId,
      this.authorisationCode,
      this.lastSynced});

  factory ChildDeviceModel.fromEntity(ChildEntity entity) => ChildDeviceModel(
        childId: entity.id!, // NONNULL CHILDID
        childName: entity.name,
        birthDate: entity.birthDate,
        deviceRemoteId: entity.deviceRemoteId,
      //  authorisationCode: entity.arduinoDeviceEntity?.authorisationCode,
        // TODO implement last synced in database
      );

  @override
  String toString() => "$childId, $childName, $birthDate, $deviceRemoteId \n";

//  factory MobileViewModel.fromJson(final Map<String, dynamic> json) =>
//       MobileViewModel(
//         countryCallingCode: json['countryCallingCode'],
//         mobileNumber: json['mobileNumber'],
//       );
}
