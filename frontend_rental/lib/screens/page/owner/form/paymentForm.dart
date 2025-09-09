import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rental/services/lease_service.dart';
import 'package:frontend_rental/services/payment_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controller/property_controller.dart';
import '../../../../models/error.dart';
import '../../../../models/payment_model.dart';
import '../../../../shared/loading.dart';
import '../../../../utils/helper.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  bool isLoading = false;
  String? id;
  late String? originalLeaseId;
  late String? originalRentAmount;
  bool isEditMode = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _leaseIdController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _receiptUrlController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final LeaseService leaseService = LeaseService();
  final propertiesController = Get.find<PropertyController>();
  final PaymentService paymentService = PaymentService();
  late Map<String, dynamic> arg;
  List utilities = [];
  final List<Map<String, dynamic>> _paymentMethodOptions = [
    {'id': 1, 'name': 'Bank Transfer'},
    {'id': 2, 'name': 'Cash'},
    {'id': 3, 'name': 'Online Payment'},
    {'id': 4, 'name': 'Mobile Wallet'},
    {'id': 5, 'name': 'QR Code'},
    {'id': 6, 'name': 'Auto-Debit'},
    {'id': 7, 'name': 'Cheque'},
    {'id': 8, 'name': 'Credit/Debit Card'},
    {'id': 9, 'name': 'Cryptocurrency'},
    {'id': 10, 'name': 'Other'},
  ];

  Future<void> _pickReceiptGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        String fullPath = pickedFile.path;
        String fileName = fullPath.split('/').last;
        _receiptUrlController.text = fileName;
      });
    }
  }

  Future<void> _pickReceiptFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final fileName = result.files.single.name;

      setState(() {
        _receiptUrlController.text = fileName;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if(propertiesController.leases.isEmpty){
        leaseService.getAllLeases();
      }
    });
    arg = (Get.arguments as Map).cast<String, dynamic>();
    if (arg.isNotEmpty) {
      final data = arg;
      isEditMode = data['id'] != null;
      id = data['id'].toString();
      originalLeaseId = data['lease_id'].toString();
      originalRentAmount = data['amount_paid'].toString();
      _leaseIdController.text = data['lease_id'].toString();
      _paymentDateController.text = data['payment_date'].toString();
      _amountPaidController.text = data['amount_paid'].toString();
      _receiptUrlController.text = data['receipt_url'].toString();
      _paymentMethodController.text = data['payment_method_id'].toString();
      if(data['meter_readings'] != null){
        utilities = data['meter_readings'];
        for(var u in utilities){
          var utilityType = u['utility_type_id'];
          if(utilityType == 1){
            _electricityController.text = u['current_reading'].toString();
          }else if(utilityType == 2){
            _waterController.text = u['current_reading'].toString();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _leaseIdController.dispose();
    _paymentDateController.dispose();
    _amountPaidController.dispose();
    _receiptUrlController.dispose();
    _paymentMethodController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      Helper.showLoadingDialog(context);
      ErrorModel errorModel;
      PaymentModel paymentModel = PaymentModel(
        leaseId: _leaseIdController.text,
        paymentDate: _paymentDateController.text,
        amountPaid: double.parse(_amountPaidController.text),
        receiptUrl: _receiptUrlController.text,
        paymentMethodId: _paymentMethodController.text,
        electricity: _electricityController.text,
        water: _waterController.text
      );

      if(id == null){
        errorModel = await paymentService.createPayment(paymentModel);
      }else{
        errorModel = await paymentService.updatePayment(id!, paymentModel);
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
    return isLoading ? const Center(child: Loading()) : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('payments'.tr, context, null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Obx(() {
                return Helper.sampleDropdownSearch(
                  context: context,
                  items: (() {
                    final Map<String, Map<String, dynamic>> uniqueLeases = {};

                    for (var lease in propertiesController.leases) {
                      final unitNumber = lease['unit_number'].toString();
                      final status = lease['status'].toString().toLowerCase();

                      if (status == 'active' && !uniqueLeases.containsKey(unitNumber)) {
                        uniqueLeases[unitNumber] = lease;
                      }

                      if (lease['id'].toString() == _leaseIdController.text && status != 'active') {
                        uniqueLeases[unitNumber] = lease;
                      }
                    }
                    return uniqueLeases.values.toList();
                  })(),
                  labelText: "leases".tr,
                  controller: _leaseIdController,
                  selectedId: _leaseIdController.text,
                  displayKey: "unit_number",
                  idKey: "id",
                  isRequired: true,
                  dropDownPrefixIcon: Icon(Icons.apartment_rounded),
                  onChanged: (value) {
                    if (value == null) return;

                    final selectedLeaseId = value['id'].toString();
                    final rentAmount = value['rent_amount'] ?? 0;

                    if (isEditMode) {
                      if (selectedLeaseId != originalLeaseId) {
                        _amountPaidController.text = rentAmount.toString();
                      } else{
                        _amountPaidController.text = originalRentAmount.toString();
                      }
                    } else {
                      _amountPaidController.text = rentAmount.toString();
                    }

                    if (value['utilities'] != null) {
                      utilities.clear();

                      for (var utility in value['utilities']) {
                        if (utility['billing_type'] == 'per_unit') {
                          utilities.add(utility);
                        }
                      }
                      setState(() {});
                    }
                  }
                );
              }),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  _showCupertinoDatePicker(context);
                },
                child: AbsorbPointer(
                  child: Helper.sampleTextField(
                    context: context,
                    controller: _paymentDateController,
                    labelText: "payment_date".tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (val) => val == null || val.isEmpty ? 'select_payment_date'.tr : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Helper.sampleTextField(
                context: context,
                controller: _amountPaidController,
                labelText: "amount_paid".tr,
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (val) => val == null || val.isEmpty ? 'amount_is_required'.tr : null,
              ),
              const SizedBox(height: 16),

              Helper.sampleDropdownSearch(
                context: context,
                items: _paymentMethodOptions,
                labelText: "select_payment_method".tr,
                controller: _paymentMethodController,
                selectedId: _paymentMethodController.text,
                displayKey: "name",
                idKey: "id",
                isRequired: true,
                dropDownPrefixIcon: const Icon(Icons.payment),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _showCupertinoActionSheet(context),
                child: AbsorbPointer(
                  child: Helper.sampleTextField(
                    context: context,
                    controller: _receiptUrlController,
                    labelText: "receipt_url".tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.link),
                    validator: (val) => val == null || val.isEmpty ? 'receipt_url_is_required'.tr : null,
                  ),
                ),
              ),

              Column(
                children: [
                  for (var utility in utilities)
                    if (utility['billing_type'] == 'per_unit')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Helper.sampleTextField(
                          context: context,
                          controller: utility['utility_type_id'] == 1 ? _electricityController : _waterController,
                          labelText: utility['utility_type_id'] == 1 ? "${"electricity".tr} (kWh)" : "${"water".tr} (m³)",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          validator: (val) => val == null || val.isEmpty ? 'this_field_is_required'.tr : null,
                          prefixIcon: Icon(utility['utility_type_id'] == 1 ? Icons.electric_bolt : Icons.water_drop),
                        ),
                      ),
                ],
              ),

              const SizedBox(height: 16),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePayment,
                  child: Text(id == null ? 'save'.tr : 'update'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCupertinoDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Get.theme.scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime picked) {
                    setState(() {
                      _paymentDateController.text = "${picked.year.toString().padLeft(4, '0')}-" "${picked.month.toString().padLeft(2, '0')}-" "${picked.day.toString().padLeft(2, '0')}";
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCupertinoActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text("file".tr),
            onPressed: () async {
              Navigator.of(context).pop();
              _pickReceiptFile();
            },
          ),
          CupertinoActionSheetAction(
            child: Text("gallery".tr),
            onPressed: () {
              Navigator.of(context).pop();
              _pickReceiptGallery();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text("cancel".tr),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
