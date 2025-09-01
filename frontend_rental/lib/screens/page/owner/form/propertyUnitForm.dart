import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/models/propertyunit_model.dart';
import 'package:frontend_rental/services/propertyService.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../../models/error.dart';
import '../../../../shared/message_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if(propertiesController.properties.isEmpty){
        propertyService.getAllProperties();
      }
    });
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
  }

  void _saveUnit() async{
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      ErrorModel errorModel;
      PropertyUnitModel unitModel = PropertyUnitModel(
          unitNumber: unitNumberController.text,
          floor: floorController.text,
          bedrooms: bedroomsController.text,
          bathrooms: bathroomsController.text,
          size: sizeController.text,
          rent: rentController.text,
          isAvailable: isAvailable,
          propertyId: propertyController.text
      );

      if(id == null){
        errorModel = await propertyService.createPropertyUnit(unitModel);
      }else{
        errorModel = await propertyService.updatePropertyUnit(id!, unitModel);
      }
      Helper.closeLoadingDialog(context);
      if (errorModel.isError == false){
        Get.back();
        Get.showSnackbar(
          GetSnackBar(
            messageText: const SizedBox.shrink(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.scaffoldBackgroundColor,
            snackStyle: SnackStyle.FLOATING,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
            borderRadius: 8,
            duration: const Duration(seconds: 3),
            isDismissible: true,
            titleText: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save, size: 25, color: Colors.grey),
                const SizedBox(width: 8),
                Text(id == null ? 'created_successfully'.tr : 'updated_successfully'.tr, style: Get.textTheme.titleMedium),
              ],
            ),
          ),
        );
      }else {
        String errorMessage = errorModel.message!.toLowerCase();

        if (errorMessage.contains('already exists')) {
          MessageDialog.showMessage('information'.tr, 'type_already_exists'.tr, context);
        } else {
          MessageDialog.showMessage('information'.tr, id == null ? 'create_failed'.tr : 'update_failed'.tr, context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar('Property Unit', context, null),
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
                  labelText: "Select Property",
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
                      labelText: "Unit Number",
                      prefixIcon: Icon(Icons.confirmation_number_rounded)
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: floorController,
                      labelText: "Floor",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.layers_rounded)
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
                      labelText: "Bedrooms",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.bed_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: bathroomsController,
                      labelText: "Bathrooms",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.bathtub_rounded),
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
                      labelText: "Size (sqm)",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.square_foot_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Helper.sampleTextField(
                      context: context,
                      controller: rentController,
                      labelText: "Rent Price (\$)",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Available"),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: isAvailable,
                      onChanged: (val) => setState(() => isAvailable = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

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
