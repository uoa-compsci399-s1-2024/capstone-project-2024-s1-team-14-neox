import '../../data/entities/child_entity.dart';
import 'child_device_model.dart';

class ChildDeviceRepository {
  // Fetch all children profiles

  Future<List<ChildDeviceModel>> fetchChildProfiles() async {
    List<ChildEntity> entities = await ChildEntity.queryAllChildren();
    return entities.map((child) => ChildDeviceModel.fromEntity(child))
          .toList();

  }


  // deletl child profile based on id


  // update child device remote id
  // add child remote id

  Future<List<ChildDeviceModel>> createChildProfile(String name, DateTime birthDate) async {
    ChildEntity.saveSingleChildEntityFromParameters(name, birthDate);
    return fetchChildProfiles();
  }
   // TODO Implement delete
  Future<List<ChildDeviceModel>> deleteChildProfile(int childId) async {
    List<ChildDeviceModel> result = [];
    return result;
  }

  // TODO implement udpdate
  Future<List<ChildDeviceModel>> updateChildDeviceRemoteID(int childId, String deviceRemoteId) async {
    List<ChildDeviceModel> result = [];
    return result;
  }
}
