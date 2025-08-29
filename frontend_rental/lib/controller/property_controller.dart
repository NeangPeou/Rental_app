import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PropertyController extends GetxController {
  final RxList<Map<String, dynamic>> properties = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> types = <Map<String, dynamic>>[].obs;

  void setListProperties(List<Map<String, dynamic>> data) {
    properties.assignAll(data);
  }

  void addProperty(Map<String, dynamic> property) {
    properties.insert(0, property);
  }

  void updateProperty(Map<String, dynamic> updatedProperty) {
    final index = properties.indexWhere((p) => p['id'] == updatedProperty['id']);
    if (index != -1) {
      properties[index] = updatedProperty;
    }
  }

  void removeProperty(String id) {
    properties.removeWhere((p) => p['id'] == int.tryParse(id));
  }

  void setListTypes(List<Map<String, dynamic>> data) {
    types.assignAll(data);
  }
}
