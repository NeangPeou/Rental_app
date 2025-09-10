import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class InventoryController extends GetxController {
  final RxList<Map<String, dynamic>> inventory = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allInventory = [];

  void setInventory(List<Map<String, dynamic>> data) {
    allInventory.clear();
    allInventory.addAll(data);
    inventory.assignAll(data);
  }

  void addInventory(Map<String, dynamic> item) {
    allInventory.insert(0, item);
    inventory.insert(0, item);
  }

  void updateInventory(Map<String, dynamic> updatedItem) {
    final index = inventory.indexWhere((i) => i['id'] == updatedItem['id']);
    if (index != -1) {
      inventory[index] = updatedItem;
      allInventory[index] = updatedItem;
    }
  }

  void removeInventory(String id) {
    final parsedId = int.tryParse(id);
    if (parsedId != null) {
      inventory.removeWhere((i) => i['id'] == parsedId);
      allInventory.removeWhere((i) => i['id'] == parsedId);
    }
  }
}