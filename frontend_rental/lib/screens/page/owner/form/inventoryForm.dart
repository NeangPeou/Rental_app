import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/inventory_controller.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/models/inventory_model.dart';
import 'package:frontend_rental/services/inventory_service.dart';
import 'package:frontend_rental/services/property_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../../models/error.dart';

class InventoryForm extends StatefulWidget {
  const InventoryForm({super.key});

  @override
  State<InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  final _formKey = GlobalKey<FormState>();
  final PropertyController propertyController = Get.find<PropertyController>();
  final InventoryController inventoryController = Get.put(InventoryController());
  final PropertyService propertyService = PropertyService();
  final InventoryService inventoryService = InventoryService();
  bool isEditMode = false;
  String? id;
  late Map<String, dynamic> arg;
  final TextEditingController unitController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (propertyController.units.isEmpty) {
        await propertyService.getAllUnits();
      }
    });
    arg = (Get.arguments as Map).cast<String, dynamic>();
    if (arg.isNotEmpty) {
      final item = arg;
      isEditMode = item['id'] != null;
      id = item['id'].toString();
      unitController.text = item['unit_id'].toString();
      itemController.text = item['item']?.toString() ?? '';
      qtyController.text = item['qty']?.toString() ?? '1';
      conditionController.text = item['condition']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    unitController.dispose();
    itemController.dispose();
    qtyController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  void _saveInventory() async {
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      ErrorModel errorModel;
      InventoryModel inventoryModel = InventoryModel(
        unitId: int.parse(unitController.text),
        item: itemController.text,
        qty: int.parse(qtyController.text),
        condition: conditionController.text,
      );

      if (id == null) {
        errorModel = await inventoryService.createInventory(inventoryModel);
      } else {
        errorModel = await inventoryService.updateInventory(id!, inventoryModel);
      }
      Helper.closeLoadingDialog(context);

      if (errorModel.isError == false) {
        Get.back();
        Helper.successSnackbar(id == null ? 'created_successfully'.tr : 'updated_successfully'.tr);
      } else {
        String errorMessage = errorModel.message!.toLowerCase();

        if (errorMessage.contains('already exists')) {
          Helper.errorSnackbar('data_already_exists'.tr);
        } else {
          Helper.errorSnackbar(id == null ? 'create_failed'.tr : 'update_failed'.tr);
        }
      }
    }
  }

  Widget _buildSection({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(120),
          width: 1,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: Helper.sampleAppBar('inventory'.tr, context, null),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(2),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("unit&item".tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Helper.sampleDropdownSearch(
                              context: context,
                              items: propertyController.units,
                              labelText: "selectUnit".tr,
                              controller: unitController,
                              selectedId: unitController.text,
                              displayKey: "unit_number",
                              idKey: "id",
                              isRequired: true,
                              dropDownPrefixIcon: const Icon(Icons.apartment_rounded),
                            );
                          }),
                          const SizedBox(height: 8),
                          Helper.sampleTextField(
                            context: context,
                            controller: itemController,
                            labelText: "itemName".tr,
                            isRequired: true,
                            prefixIcon: const Icon(Icons.inventory),
                            validator: (value) =>
                                value!.isEmpty ? 'please_enter_item_name'.tr : null,
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("details".tr,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Helper.sampleTextField(
                            context: context,
                            controller: qtyController,
                            labelText: "quantity".tr,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            prefixIcon: const Icon(Icons.numbers),
                            validator: (value) {
                              if (value!.isEmpty) return 'please_enter_quantity'.tr;
                              if (int.tryParse(value) == null || int.parse(value) < 1) {
                                return 'Quantity must be a positive number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Helper.sampleDropdownSearch(
                            context: context,
                            items: [
                              {'id': 'new', 'condition': 'New'},
                              {'id': 'good', 'condition': 'Good'},
                              {'id': 'fair', 'condition': 'Fair'},
                              {'id': 'poor', 'condition': 'Poor'},
                            ],
                            labelText: "condition".tr,
                            controller: conditionController,
                            selectedId: conditionController.text,
                            displayKey: "condition",
                            idKey: "id",
                            isRequired: true,
                            dropDownPrefixIcon: const Icon(Icons.build),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveInventory,
                        child: Text(
                          id == null ? 'save'.tr : 'update'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}