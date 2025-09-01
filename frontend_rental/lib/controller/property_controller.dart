import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PropertyController extends GetxController {
  final RxList<Map<String, dynamic>> properties = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allProperties = [];
  final RxList<Map<String, dynamic>> types = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> units = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allUnits = [];

  void setListProperties(List<Map<String, dynamic>> data) {
    allProperties.clear();
    allProperties.addAll(data);
    properties.assignAll(data);
  }

  void addProperty(Map<String, dynamic> property) {
    allProperties.insert(0, property);
    properties.insert(0, property);
  }

  void updateProperty(Map<String, dynamic> updatedProperty) {
    final index = properties.indexWhere((p) => p['id'] == updatedProperty['id']);
    if (index != -1) {
      properties[index] = updatedProperty;
      allProperties[index] = updatedProperty;
    }
  }

  void removeProperty(String id) {
    properties.removeWhere((p) => p['id'] == int.tryParse(id));
    allProperties.removeWhere((p) => p['id'] == int.tryParse(id));
  }

  void setListTypes(List<Map<String, dynamic>> data) {
    types.assignAll(data);
  }

  /// Set unit list
  void setUnits(List<Map<String, dynamic>> data) {
    allUnits.clear();
    allUnits.addAll(data);
    units.assignAll(data);
  }

  /// Add new unit
  void addUnit(Map<String, dynamic> unit) {
    allUnits.insert(0, unit);
    units.insert(0, unit);
  }

  /// Update a unit by ID
  void updateUnit(Map<String, dynamic> updatedUnit) {
    final index = units.indexWhere((u) => u['id'] == updatedUnit['id']);
    if (index != -1) {
      units[index] = updatedUnit;
      allUnits[index] = updatedUnit;
    }
  }

  /// Delete a unit by ID
  void removeUnit(String id) {
    int? parsedId = int.tryParse(id);
    if (parsedId != null) {
      units.removeWhere((u) => u['id'] == parsedId);
      allUnits.removeWhere((u) => u['id'] == parsedId);
    }
  }
}
