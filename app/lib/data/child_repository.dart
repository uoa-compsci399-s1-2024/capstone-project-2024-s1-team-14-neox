import 'child_model.dart';

class ChildRepository {
  List<ChildModel> childProflieList = <ChildModel>[];

  List<ChildModel> fetchChildProfiles() => childProflieList;

  Future<List<ChildModel>> createChildProfile(
      String name, DateTime dateOfBirth) async {
    childProflieList.add(ChildModel(name, dateOfBirth, null));
    return childProflieList;
  }

  Future<List<ChildModel>> deleteChildProfile(int index) async {
    childProflieList.removeAt(index);
    return childProflieList;
  }

  Future<List<ChildModel>> updateChildDeviceRemoteID(String name, String? deviceRemoteId) async{
    childProflieList[childProflieList
            .indexWhere((element) => element.name == name)]
        .updateDeviceRemoteId(deviceRemoteId);
    return childProflieList; 
  }

  void convertBytes(List<int> byteArray) {
    //TODO convert bytes to model
    // Append to database
  }
}
