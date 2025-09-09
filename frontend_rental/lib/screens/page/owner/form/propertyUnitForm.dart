import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/models/propertyunit_model.dart';
import 'package:frontend_rental/services/property_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../../models/error.dart';
import '../../../../models/utility_model.dart';

class PropertyUnitForm extends StatefulWidget {
  const PropertyUnitForm({super.key});

  @override
  State<PropertyUnitForm> createState() => _PropertyUnitFormState();
}

class _PropertyUnitFormState extends State<PropertyUnitForm> {
  final _formKey = GlobalKey<FormState>();
  final propertiesController = Get.find<PropertyController>();
  final PropertyService propertyService = PropertyService();
  bool isAvailable = true;
  String? id;
  late Map<String, dynamic> arg;
  final TextEditingController unitNumberController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController bedroomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController propertyController = TextEditingController();
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _internetController = TextEditingController();
  final TextEditingController _electricityBillingTypeController = TextEditingController();
  final TextEditingController _waterBillingTypeController = TextEditingController();
  final List<Map<String, dynamic>> _billingMethodOptions = [
    {'id': 'per_unit', 'name': 'Per Unit'},
    {'id': 'fixed', 'name': 'Fixed'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if(propertiesController.properties.isEmpty){
        propertyService.getAllProperties();
      }
    });
    if(_electricityBillingTypeController.text.isEmpty){
      _electricityBillingTypeController.text = 'fixed';
    }
    if(_waterBillingTypeController.text.isEmpty){
      _waterBillingTypeController.text = 'fixed';
    }
    arg = (Get.arguments as Map).cast<String, dynamic>();
    if (arg.isNotEmpty) {
      final property = arg;
      id = property['id'].toString();
      unitNumberController.text = property['unit_number'].toString();
      floorController.text = property['floor']?.toString() ?? '';
      bedroomsController.text = property['bedrooms']?.toString() ?? '';
      bathroomsController.text = property['bathrooms']?.toString() ?? '';
      sizeController.text = property['size']?.toString() ?? '';
      rentController.text = property['rent']?.toString() ?? '';
      propertyController.text = property['property_id']?.toString() ?? '';
      isAvailable = property['is_available'];
      if (property['utilities'] != null) {
        for (var u in property['utilities']) {
          String utilityType = u['utility_type_id'].toString();
          String billingType = u['billing_type'];
          String amount = billingType == 'fixed' ? u['fixed_rate'].toString() : u['unit_rate'].toString();

          if (utilityType == '1') {
            _electricityBillingTypeController.text = billingType;
            _electricityController.text = amount;
          } else if (utilityType == '2') {
            _waterBillingTypeController.text = billingType;
            _waterController.text = amount;
          } else if (utilityType == '3') {
            _internetController.text = u['fixed_rate']?.toString() ?? '';
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    unitNumberController.dispose();
    floorController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    sizeController.dispose();
    rentController.dispose();
    propertyController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _internetController.dispose();
    _electricityBillingTypeController.dispose();
    _waterBillingTypeController.dispose();
  }

  void _saveUnit() async{
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      List<UtilityModel> utilities = [];

      if (_electricityController.text.isNotEmpty) {
        utilities.add(UtilityModel(
          utilityType: '1',
          billingType: _electricityBillingTypeController.text,
          amount: _electricityController.text,
        ));
      }

      if (_waterController.text.isNotEmpty) {
        utilities.add(UtilityModel(
          utilityType: '2',
          billingType: _waterBillingTypeController.text,
          amount: _waterController.text,
        ));
      }

      if (_internetController.text.isNotEmpty) {
        utilities.add(UtilityModel(
          utilityType: '3',
          billingType: 'fixed',
          amount: _internetController.text,
        ));
      }
      ErrorModel errorModel;
      PropertyUnitModel unitModel = PropertyUnitModel(
          unitNumber: unitNumberController.text,
          floor: floorController.text,
          bedrooms: bedroomsController.text,
          bathrooms: bathroomsController.text,
          size: sizeController.text,
          rent: rentController.text,
          isAvailable: isAvailable,
          propertyId: propertyController.text,
          utilities: utilities,
      );

      if(id == null){
        errorModel = await propertyService.createPropertyUnit(unitModel);
      }else{
        errorModel = await propertyService.updatePropertyUnit(id!, unitModel);
      }
      Helper.closeLoadingDialog(context);
      if (errorModel.isError == false){
        Get.back();
        Helper.successSnackbar(id == null ? 'created_successfully'.tr : 'updated_successfully'.tr);
      }else {
        String errorMessage = errorModel.message!.toLowerCase();

        if (errorMessage.contains('already exists')) {
          Helper.errorSnackbar('data_already_exists'.tr);
        } else {
          Helper.errorSnackbar(id == null ? 'create_failed'.tr : 'update_failed'.tr);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar('property_unit'.tr, context, null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Obx(() {
                return Helper.sampleDropdownSearch(
                  context: context,
                  items: propertiesController.properties.isEmpty ? [] : propertiesController.properties,
                  labelText: "select_property".tr,
                  controller: propertyController,
                  selectedId: propertyController.text,
                  displayKey: "name",
                  idKey: "id",
                  isRequired: true,
                  dropDownPrefixIcon: Icon(Icons.apartment_rounded),
                );
              }),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:  Helper.sampleTextField(
                      context: context,
                      controller: unitNumberController,
                      labelText: "unit_number".tr,
                      isRequired: true,
                      prefixIcon: Icon(Icons.confirmation_number_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: floorController,
                      labelText: "floor".tr,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.layers_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:  Helper.sampleTextField(
                      context: context,
                      controller: bedroomsController,
                      labelText: "bedrooms".tr,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.bed_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: bathroomsController,
                      labelText: "bathrooms".tr,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.bathtub_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:   Helper.sampleTextField(
                      context: context,
                      controller: sizeController,
                      labelText: "size_sqm".tr,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.square_foot_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: rentController,
                      labelText: "${'rent_price'.tr} (\$)",
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      validator: (value) => value == null || value.isEmpty ? 'this_field_is_required'.tr : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Helper.sampleDropdownSearch(
                      context: context,
                      items: _billingMethodOptions,
                      labelText: "select_billing_type".tr,
                      controller: _electricityBillingTypeController,
                      selectedId: _electricityBillingTypeController.text.isEmpty ? "fixed" : _electricityBillingTypeController.text,
                      displayKey: "name",
                      idKey: "id",
                      dropDownPrefixIcon: const Icon(Icons.electric_bolt),
                      onChanged: (selected) {
                        if (selected != null) {
                          _electricityController.text = "";
                          _electricityBillingTypeController.text = selected['id'];
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: _electricityController,
                      labelText: _electricityBillingTypeController.text.isEmpty ? "USD" : _electricityBillingTypeController.text == "fixed" ? "USD" : "${"rate".tr}(kWh)",
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icon(_electricityBillingTypeController.text.isEmpty ? Icons.attach_money_rounded : _electricityBillingTypeController.text == "fixed" ? Icons.attach_money_rounded  : Icons.electric_bolt),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Helper.sampleDropdownSearch(
                      context: context,
                      items: _billingMethodOptions,
                      labelText: "select_billing_type".tr,
                      controller: _waterBillingTypeController,
                      selectedId: _waterBillingTypeController.text.isEmpty ? "fixed" : _waterBillingTypeController.text,
                      displayKey: "name",
                      idKey: "id",
                      dropDownPrefixIcon: Icon(Icons.water_drop),
                      onChanged: (selected) {
                        if (selected != null) {
                          _waterController.text = "";
                          _waterBillingTypeController.text = selected['id'];
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Helper.sampleTextField(
                        context: context,
                        controller: _waterController,
                        labelText: _waterBillingTypeController.text.isEmpty ? "USD" : _waterBillingTypeController.text != "fixed" ? "${"rate".tr}(m³)" : "USD",
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icon(_waterBillingTypeController.text.isEmpty ? Icons.attach_money_rounded : _waterBillingTypeController.text == "fixed" ? Icons.attach_money_rounded : Icons.water_drop),
                      )
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Helper.sampleTextField(
                context: context,
                controller: _internetController,
                labelText: "internet".tr,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("available".tr),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: isAvailable,
                      onChanged: (val) => setState(() => isAvailable = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUnit,
                  child: Text(id == null ? 'save'.tr : 'update'.tr),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
