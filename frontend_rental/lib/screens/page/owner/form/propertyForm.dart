import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controller/property_controller.dart';
import '../../../../models/error.dart';
import '../../../../models/property_model.dart';
import '../../../../services/property_service.dart';
import '../../../../shared/loading.dart';
import '../../../../utils/helper.dart';
import 'package:get/get.dart';

class PropertyForm extends StatefulWidget {
  const PropertyForm({super.key});

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final dropDownKey = GlobalKey<DropdownSearchState>();
  List<XFile>? _pickedImages;
  final ImagePicker _picker = ImagePicker();
  late Map<String, dynamic> arg;
  String? id;
  bool isLoading = true;
  final types = Get.find<PropertyController>().types;
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTypes();
    arg = (Get.arguments as Map).cast<String, dynamic>();
    if (arg.isNotEmpty) {
      final property = arg;
      id = property['id'].toString();
      _nameController.text = property['name'] ?? '';
      _addressController.text = property['address'] ?? '';
      _cityController.text = property['city'] ?? '';
      _districtController.text = property['district'] ?? '';
      _provinceController.text = property['province'] ?? '';
      _postalCodeController.text = property['postal_code']?.toString() ?? '';
      _latitudeController.text = property['latitude']?.toString() ?? '';
      _longitudeController.text = property['longitude']?.toString() ?? '';
      _descriptionController.text = property['description'] ?? '';
      _typeIdController.text = property['type_id']?.toString() ?? '';
      _ownerIdController.text = property['owner_id']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    _typeIdController.dispose();
    _ownerIdController.dispose();
    super.dispose();
  }

  void _saveProperty() async{
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      ErrorModel errorModel;
      PropertyModel property = PropertyModel(
          name: _nameController.text,
          address: _addressController.text,
          city: _cityController.text,
          district: _districtController.text,
          province: _provinceController.text,
          postalCode: _postalCodeController.text,
          latitude: _latitudeController.text,
          longitude: _longitudeController.text,
          typeId: _typeIdController.text,
          ownerId: _ownerIdController.text,
          description: _descriptionController.text
      );
      if(id == null){
        errorModel = await _propertyService.createProperty(property);
      }else{
        errorModel = await _propertyService.updateProperty(id!, property);
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          _pickedImages = selectedImages;
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getTypes() async {
    if(types.isEmpty){
      ErrorModel errorModel = await _propertyService.getAllTypes();
      if(errorModel.isError == true){
        Get.back();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  String? validateCoordinate(String? value, {required bool isLatitude}) {
    if (value == null || value.trim().isEmpty) {
      return 'this_field_is_required'.tr;
    }

    final trimmed = value.trim();

    if (!trimmed.contains('.')) {
      return 'must_include_decimal_e_g_10_123456'.tr;
    }

    final num? parsed = num.tryParse(trimmed);
    if (parsed == null) return 'invalid_number'.tr;

    final rangeValid = isLatitude ? (parsed >= -90 && parsed <= 90) : (parsed >= -180 && parsed <= 180);

    if (!rangeValid) {
      return isLatitude ? 'latitude_must_be_between_-90_and_90'.tr : 'longitude_must_be_between_-180_and_180'.tr;
    }

    final decimalPart = trimmed.split('.')[1];
    if (decimalPart.length > 6) {
      return 'max_6_decimal_places_allowed'.tr;
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: Loading()) : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('property'.tr, context, null),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.theme.splashColor,
          ),
          child: Column(
            children: [
              Text('get_started_managing_your_property'.tr, style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Get.theme.cardColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Helper.sampleTextField(
                            context: context,
                            controller: _nameController,
                            labelText: 'name'.tr,
                            isRequired: true,
                            validator: (value) => value == null || value.isEmpty ? 'please_enter_name'.tr : null,
                            prefixIcon: const Icon(Icons.house),
                          ),
                          const SizedBox(height: 16),
                          Helper.sampleTextField(
                            context: context,
                            controller: _addressController,
                            labelText: 'address'.tr,
                            isRequired: true,
                            validator: (value) => value == null || value.isEmpty ? 'please_enter_address'.tr : null,
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _cityController,
                                  labelText: 'city'.tr,
                                  isRequired: true,
                                  validator: (value) => value == null || value.isEmpty ? 'please_enter_city'.tr : null,
                                  prefixIcon: const Icon(Icons.location_city),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _districtController,
                                  labelText: 'district'.tr,
                                  prefixIcon: const Icon(Icons.home),
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
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _provinceController,
                                  labelText: 'province'.tr,
                                  prefixIcon: const Icon(Icons.approval_rounded),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _postalCodeController,
                                  labelText: 'postal_code'.tr,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Icons.local_post_office),
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
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _latitudeController,
                                  labelText: 'latitude'.tr,
                                  isRequired: true,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => validateCoordinate(value, isLatitude: true),
                                  prefixIcon: const Icon(Icons.gps_fixed_rounded),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Helper.sampleTextField(
                                  context: context,
                                  controller: _longitudeController,
                                  labelText: 'longitude'.tr,
                                  isRequired: true,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) => validateCoordinate(value, isLatitude: false),
                                  prefixIcon: const Icon(Icons.gps_fixed_rounded),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() => Helper.sampleDropdownSearch(
                            context: context,
                            items: Get.find<PropertyController>().types,
                            labelText: 'property_type'.tr,
                            controller: _typeIdController,
                            displayKey: 'typeCode',
                            idKey: 'id',
                            selectedId: _typeIdController.text,
                            isRequired: true,
                            dropDownPrefixIcon: const Icon(Icons.apartment),
                          )),
                          const SizedBox(height: 16),
                          Helper.sampleTextField(
                            context: context,
                            controller: _descriptionController,
                            labelText: '${'description'.tr}(${'optional'.tr})',
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            prefixIcon: const Icon(Icons.description),
                          ),
                          const SizedBox(height: 16),
                          Text('add_image'.tr, style: Get.textTheme.bodySmall),
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              padding: _pickedImages == null || _pickedImages!.isEmpty ? const EdgeInsets.all(30) : EdgeInsets.zero,
                              margin: const EdgeInsets.only(top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Get.theme.cardColor,
                                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
                              ),
                              child: _pickedImages != null && _pickedImages!.isNotEmpty ?
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _pickedImages!.map((image) => Image.file(File(image.path), width: 100, height: 100, fit: BoxFit.cover)).toList(),
                              ) : Icon(Icons.camera_alt_rounded, size: 40, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProperty,
                    child: Text(id == null ? 'save'.tr : 'update'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
