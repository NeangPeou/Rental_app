import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PropertyController extends GetxController {
  final RxList<Map<String, dynamic>> properties = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allProperties = [];
  final RxList<Map<String, dynamic>> types = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> units = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allUnits = [];
  final RxList<Map<String, dynamic>> leases = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allLeases = [];
  final RxList<Map<String, dynamic>> renters = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allRenters = [];

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

  void setLeases(List<Map<String, dynamic>> data) {
    allLeases.clear();
    allLeases.addAll(data);
    leases.assignAll(data);
  }

  void addLease(Map<String, dynamic> lease) {
    allLeases.insert(0, lease);
    leases.insert(0, lease);
    if (lease['unit_id'] != null) {
      final unitIndex = units.indexWhere((u) {
        return u['id'] == lease['unit_id'].toString();
      });

      if (unitIndex != -1) {
        units[unitIndex]['is_available'] = lease['is_available'];
        allUnits[unitIndex]['is_available'] = lease['is_available'];
      }
    }
  }

  void updateLease(Map<String, dynamic> updatedLease) {
    final index = leases.indexWhere((l) => l['id'] == updatedLease['id']);
    if (index != -1) {
      leases[index] = updatedLease;
      allLeases[index] = updatedLease;
      if (updatedLease['unit_id'] != null) {
        final unitIndex = units.indexWhere((u) {
          return u['id'] == updatedLease['unit_id'].toString();
        });

        if (unitIndex != -1) {
          units[unitIndex]['is_available'] = updatedLease['is_available'];
          allUnits[unitIndex]['is_available'] = updatedLease['is_available'];
        }
      }
    }
  }

  void removeLease(String id) {
    final parsedId = int.tryParse(id);
    if (parsedId != null) {
      leases.removeWhere((l) => l['id'] == parsedId);
      allLeases.removeWhere((l) => l['id'] == parsedId);
    }
  }

  void setRenters(List<Map<String, dynamic>> data) {
    allRenters.clear();
    allRenters.addAll(data);
    renters.assignAll(data);
  }

  void addRenter(Map<String, dynamic> data) {
    allRenters.insert(0, data);
    renters.insert(0, data);
  }

  void updateRenter(Map<String, dynamic> updatedRenter) {
    final id = int.tryParse(updatedRenter['id'].toString());
    if (id == null) return;
    final index = renters.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      renters[index] = updatedRenter;
    }
    final allIndex = allRenters.indexWhere((r) => r['id'] == id);
    if (allIndex != -1) {
      allRenters[allIndex] = updatedRenter;
    }
  }

  void removeRenter(String id) {
    final parsedId = int.tryParse(id);
    if (parsedId == null) return;

    renters.removeWhere((r) => r['id'].toString() == id || r['id'] == parsedId);
    allRenters.removeWhere((r) => r['id'].toString() == id || r['id'] == parsedId);
  }
}
