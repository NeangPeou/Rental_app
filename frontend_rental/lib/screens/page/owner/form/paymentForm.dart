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
import '../../../../shared/message_dialog.dart';
import '../../../../utils/helper.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  bool isLoading = false;
  String? id;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _leaseIdController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _receiptUrlController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final LeaseService leaseService = LeaseService();
  final propertiesController = Get.find<PropertyController>();
  final PaymentService paymentService = PaymentService();
  late Map<String, dynamic> arg;
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
      id = data['id'].toString();
      _leaseIdController.text = data['lease_id'].toString();
      _paymentDateController.text = data['payment_date'].toString();
      _amountPaidController.text = data['amount_paid'].toString();
      _receiptUrlController.text = data['receipt_url'].toString();
      _paymentMethodController.text = data['payment_method_id'].toString();
    }
  }

  @override
  void dispose() {
    _leaseIdController.dispose();
    _paymentDateController.dispose();
    _amountPaidController.dispose();
    _receiptUrlController.dispose();
    _paymentMethodController.dispose();
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
      );

      if(id == null){
        errorModel = await paymentService.createPayment(paymentModel);
      }else{
        errorModel = await paymentService.updatePayment(id!, paymentModel);
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
    return isLoading ? const Center(child: Loading()) : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('payment'.tr, context, null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Obx(() {
                return Helper.sampleDropdownSearch(
                  context: context,
                  items: propertiesController.leases.isEmpty ? [] : propertiesController.leases,
                  labelText: "Leases",
                  controller: _leaseIdController,
                  selectedId: _leaseIdController.text,
                  displayKey: "unit_number",
                  idKey: "id",
                  isRequired: true,
                  dropDownPrefixIcon: Icon(Icons.apartment_rounded),
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
                    labelText: "Payment Date",
                    isRequired: true,
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (val) => val == null || val.isEmpty ? 'Select payment date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Helper.sampleTextField(
                context: context,
                controller: _amountPaidController,
                labelText: "Amount Paid",
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (val) => val == null || val.isEmpty ? 'Amount is required' : null,
              ),
              const SizedBox(height: 16),

              Helper.sampleDropdownSearch(
                context: context,
                items: _paymentMethodOptions,
                labelText: "Select Payment Method",
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
                    labelText: "Receipt URL",
                    isRequired: true,
                    prefixIcon: const Icon(Icons.link),
                    validator: (val) => val == null || val.isEmpty ? 'Receipt URL is required' : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
