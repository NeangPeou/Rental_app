import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/inventory_controller.dart';
import 'package:frontend_rental/screens/page/owner/form/inventoryForm.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../services/inventory_service.dart';
import '../../../shared/loading.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController searchController = TextEditingController();
  final InventoryController inventoryController = Get.put(InventoryController());
  bool isLoading = true;

  // Selection mode
  bool isSelectionMode = false;
  RxSet<String> selectedItems = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void filter(String query) {
    if (query.isEmpty) {
      inventoryController.inventory.assignAll(inventoryController.allInventory);
    } else {
      final queryLower = query.toLowerCase();
      inventoryController.inventory.assignAll(
        inventoryController.allInventory.where((item) {
          return [
            item['item']?.toString().toLowerCase() ?? '',
            item['unit_number']?.toString().toLowerCase() ?? '',
            item['condition']?.toString().toLowerCase() ?? '',
          ].any((field) => field.contains(queryLower));
        }).toList(),
      );
    }
  }

  Future<void> _refreshData() async {
    await _inventoryService.getAllInventory();
    setState(() {
      isLoading = false;
      selectedItems.clear();
      isSelectionMode = false;
    });
  }

  Future<void> _deleteItem(String itemId) async {
    await _inventoryService.deleteInventory(itemId);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('inventory'.tr, context, null),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                Helper.smallSearchField(
                  context: context,
                  controller: searchController,
                  onChanged: (value) => filter(value),
                  hintText: 'search'.tr,
                ),
                const SizedBox(height: 10),
                if (isSelectionMode)
                  Obx(() => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Get.theme.dividerColor.withAlpha(120)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Helper.selectAllCheckbox(
                                  selectedItems: selectedItems,
                                  items: inventoryController.inventory,
                                  label: 'selectall'.tr,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: selectedItems.isEmpty
                                      ? null
                                      : () async {
                                          final confirm = await Helper.showDeleteConfirmationDialog(
                                              context, 'selected items');
                                          if (confirm == true) {
                                            for (var itemId in selectedItems) {
                                              await _deleteItem(itemId);
                                            }
                                            selectedItems.clear();
                                            setState(() {
                                              isSelectionMode = false;
                                            });
                                            _refreshData();
                                          }
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      isSelectionMode = false;
                                      selectedItems.clear();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                Expanded(
                  child: Obx(() {
                    if (inventoryController.inventory.isEmpty) {
                      return Helper.emptyData();
                    }
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        itemCount: inventoryController.inventory.length,
                        itemBuilder: (context, index) {
                          final item = inventoryController.inventory[index];
                          final itemId = item['id'].toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Get.theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Get.theme.dividerColor.withAlpha(120)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (isSelectionMode)
                                  Obx(() => Checkbox(
                                        value: selectedItems.contains(itemId),
                                        onChanged: (val) {
                                          if (val == true) {
                                            selectedItems.add(itemId);
                                          } else {
                                            selectedItems.remove(itemId);
                                          }
                                        },
                                      )),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      if (isSelectionMode) {
                                        if (selectedItems.contains(itemId)) {
                                          selectedItems.remove(itemId);
                                        } else {
                                          selectedItems.add(itemId);
                                        }
                                      } else {
                                        Get.to(() => InventoryForm(), arguments: item);
                                      }
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        isSelectionMode = true;
                                        selectedItems.add(itemId);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                            right: Radius.circular(12),
                                          ),
                                          child: Image.asset(
                                            'assets/app_icon/sw_logo.png',
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['item'] ?? 'Unknown Item',
                                                  style: Get.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.apartment_rounded,
                                                        size: 14, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        'unit: ${item['unit_number'] ?? ''}',
                                                        style: Get.textTheme.bodySmall,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade100,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Text(
                                                        'Qty: ${item['qty'] ?? 0}',
                                                        style: Get.textTheme.bodySmall
                                                            ?.copyWith(color: Colors.blue[800]),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getConditionColor(item['condition'] ?? ''),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Text(
                                                        item['condition'] ?? '',
                                                        style: Get.textTheme.bodySmall?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(17), bottom: Radius.circular(17)),
          border: Border.all(color: Theme.of(context).primaryColorDark.withAlpha(100)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: FloatingActionButton(
            onPressed: () {
              Get.to(() => InventoryForm(), arguments: {});
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
Color _getConditionColor(String condition) {
  switch (condition.toLowerCase()) {
    case 'new':
      return Colors.blue;   // Example: Blue for New
    case 'good':
      return Colors.green;  // Example: Green for Good
    case 'fair':
      return Colors.orange; // Example: Orange for Fair
    case 'poor':
      return Colors.red;    // Example: Red for Poor
    default:
      return Colors.grey;   // Fallback
  }
}