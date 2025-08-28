import 'package:get/get.dart';

class TypeController extends GetxController {
  final RxList<Map<String, dynamic>> listTypes = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allTypes = [];

  void setListTypes(List<Map<String, dynamic>> types) {
    allTypes.clear();
    allTypes.addAll(types);
    listTypes.assignAll(types);
  }

  void addType(Map<String, dynamic> type) {
    allTypes.insert(0, type);
    listTypes.insert(0, type);
  }

  void updateType(Map<String, dynamic> updatedType) {
    int listIndex = listTypes.indexWhere((type) => type['id'].toString() == updatedType['id'].toString());
    if (listIndex != -1) {
      listTypes[listIndex] = updatedType;
    }

    int allIndex = allTypes.indexWhere((type) => type['id'].toString() == updatedType['id'].toString());
    if (allIndex != -1) {
      allTypes[allIndex] = updatedType;
    }

    listTypes.refresh();
  }

  void removeType(String id) {
    listTypes.removeWhere((type) => type['id'].toString() == id.toString());
    allTypes.removeWhere((type) => type['id'].toString() == id.toString());
  }
}