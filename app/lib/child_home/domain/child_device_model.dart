import '../../data/entities/child_entity.dart';

class ChildDeviceModel {
  final int childId;
  final String childName;
  final DateTime birthDate;
  final String gender;
  int? outdoorTimeToday;
  int? outdoorTimeWeek;
  int? outdoorTimeMonth;
  String? deviceRemoteId;
  String? authorisationCode;
  DateTime? lastSynced;

  ChildDeviceModel(
      {required this.childId,
      required this.childName,
      required this.birthDate,
      required this.gender,
      this.deviceRemoteId,
      this.authorisationCode,
      this.outdoorTimeToday,
      this.outdoorTimeWeek,
      this.outdoorTimeMonth,
      this.lastSynced});

  factory ChildDeviceModel.fromEntity(ChildEntity entity) => ChildDeviceModel(
        childId: entity.id!, // NONNULL CHILDID
        childName: entity.name,
        birthDate: entity.birthDate,
        gender: entity.gender,
        deviceRemoteId: entity.deviceRemoteId,
        authorisationCode: entity.authorisationCode,
        // TODO implement last synced in database
      );

  @override
  String toString() => "$childId, $childName, $birthDate, $deviceRemoteId \n";
}
