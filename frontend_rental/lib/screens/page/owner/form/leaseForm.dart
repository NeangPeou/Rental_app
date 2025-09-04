import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/models/lease_model.dart';
import 'package:frontend_rental/services/lease_service.dart';
import 'package:frontend_rental/services/property_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../../models/error.dart';

class LeaseForm extends StatefulWidget {
  const LeaseForm({super.key});

  @override
  State<LeaseForm> createState() => _LeaseFormState();
}

class _LeaseFormState extends State<LeaseForm> {
  final _formKey = GlobalKey<FormState>();
  final propertiesController = Get.find<PropertyController>();
  final PropertyService propertyService = PropertyService();
  final LeaseService leaseService = LeaseService();
  bool isEditMode = false;
  String? id;
  late Map<String, dynamic> arg;

  final TextEditingController unitController = TextEditingController();
  final TextEditingController renterController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController rentAmountController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();

  String status = 'active';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async{
      if (propertiesController.units.isEmpty) {
        await propertyService.getAllUnits();
      }
       await leaseService.getAllRenters();
    });
    arg = (Get.arguments as Map).cast<String, dynamic>();
    if (arg.isNotEmpty) {
      final lease = arg;
      isEditMode = lease['id'] != null;
      id = lease['id'].toString();
      unitController.text = lease['unit_id'].toString();
      renterController.text = lease['renter_id'].toString();
      startDateController.text = lease['start_date']?.toString() ?? '';
      endDateController.text = lease['end_date']?.toString() ?? '';
      rentAmountController.text = lease['rent_amount']?.toString() ?? '';
      depositAmountController.text = lease['deposit_amount']?.toString() ?? '';
      status = lease['status']?.toString() ?? 'active';
    }
  }

  @override
  void dispose() {
    super.dispose();
    unitController.dispose();
    renterController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    rentAmountController.dispose();
    depositAmountController.dispose();
  }

  void _saveLease() async {
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      ErrorModel errorModel;
      LeaseModel leaseModel = LeaseModel(
        unitId: int.parse(unitController.text),
        renterId: int.parse(renterController.text),
        startDate: startDateController.text,
        endDate: endDateController.text,
        rentAmount: double.parse(rentAmountController.text),
        depositAmount: depositAmountController.text.isEmpty
            ? null
            : double.parse(depositAmountController.text),
        status: status,
      );

      if (id == null) {
        errorModel = await leaseService.createLease(leaseModel);
      } else {
        errorModel = await leaseService.updateLease(id!, leaseModel);
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = Helper.formatDate(picked);
    }
  }

  Widget _buildSection({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
        color: Theme.of(context).dividerColor.withAlpha(120), // Border color
        width: 1, // Border width
      ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: Helper.sampleAppBar('Lease', context, null),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
            borderRadius: BorderRadius.circular(10)
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
                        Text("Unit & Renter",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Obx(() {
                          return Helper.sampleDropdownSearch(
                            context: context,
                            items: propertiesController.units.where((unit) => unit['is_available'] == true || (isEditMode && unit['id'] == unitController.text)).toList(),
                            labelText: "Select Unit",
                            controller: unitController,
                            selectedId: unitController.text,
                            displayKey: "unit_number",
                            idKey: "id",
                            isRequired: true,
                            dropDownPrefixIcon: const Icon(Icons.apartment_rounded),
                          );
                        }),
                        const SizedBox(height: 8),
                        Obx(() {
                          return Helper.sampleDropdownSearch(
                            context: context,
                            items: propertiesController.renters,
                            labelText: "Select Renter",
                            controller: renterController,
                            selectedId: renterController.text,
                            displayKey: "username",
                            idKey: "id",
                            isRequired: true,
                            dropDownPrefixIcon: const Icon(Icons.person),
                          );
                        }),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lease Dates",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Helper.sampleTextField(
                          context: context,
                          controller: startDateController,
                          labelText: "Start Date",
                          readOnly: true,
                          onTap: () => _selectDate(context, startDateController),
                          isRequired: true,
                          prefixIcon: const Icon(Icons.calendar_today),
                          validator: (value) =>
                              value!.isEmpty ? 'Please select a start date' : null,
                        ),
                        const SizedBox(height: 8),
                        Helper.sampleTextField(
                          context: context,
                          controller: endDateController,
                          labelText: "End Date",
                          readOnly: true,
                          onTap: () => _selectDate(context, endDateController),
                          isRequired: true,
                          prefixIcon: const Icon(Icons.calendar_today),
                          validator: (value) =>
                              value!.isEmpty ? 'Please select an end date' : null,
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Payment Info",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Helper.sampleTextField(
                          context: context,
                          controller: rentAmountController,
                          labelText: "Rent Amount (\$)",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter rent amount' : null,
                        ),
                        const SizedBox(height: 8),
                        Helper.sampleTextField(
                          context: context,
                          controller: depositAmountController,
                          labelText: "Deposit Amount (\$)",
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.savings),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Helper.sampleDropdownSearch(
                      context: context,
                      items: [
                        {'id': 'active', 'status': 'Active'},
                        {'id': 'terminated', 'status': 'Terminated'},
                        {'id': 'expired', 'status': 'Expired'},
                      ],
                      labelText: "Status",
                      controller: TextEditingController(text: status),
                      selectedId: status,
                      displayKey: "status",
                      idKey: "id",
                      isRequired: true,
                      onChanged: (selected) {
                        if (selected != null) {
                          status = selected['id'];
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: Get.width, // smaller width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // smaller padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // smaller radius
                        ),
                      ),
                      onPressed: _saveLease,
                      child: Text(
                        id == null ? 'save'.tr : 'update'.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white), // smaller font
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
