import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rental/services/invoice_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../../controller/invoice_controller.dart';
import '../../../../models/error.dart';
import '../../../../shared/loading.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String? id;
  final TextEditingController unitController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  InvoiceService invoiceService = InvoiceService();
  final invoiceController = Get.find<InvoiceController>();

  @override
  void initState() {
    super.initState();
    getLeases();
  }

  Future<void> getLeases() async {
    ErrorModel errorModel = await invoiceService.getActiveLeases();
    if(errorModel.isError == true){
      Get.back();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: Loading()) : Scaffold(
      appBar: Helper.sampleAppBar('invoice'.tr, context, null),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Helper.sampleDropdownSearch(
                context: context,
                items: invoiceController.activeLeases,
                labelText: "unit_number".tr,
                controller: unitController,
                selectedId: unitController.text,
                displayKey: "unit_number",
                idKey: "lease_id",
                isRequired: true,
                dropDownPrefixIcon: Icon(Icons.apartment_rounded),
                validator: (val) => val == null || val.isEmpty ? 'this_field_is_required'.tr : null,
              ),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showCupertinoDatePicker(context);
                },
                child: AbsorbPointer(
                  child: Helper.sampleTextField(
                    context: context,
                    controller: _paymentDateController,
                    labelText: "month".tr,
                    isRequired: true,
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (val) => val == null || val.isEmpty ? 'this_field_is_required'.tr : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Helper.showLoadingDialog(context);
                    ErrorModel errorModel;
                    if(id == null){
                      errorModel = await invoiceService.createInvoice(unitController.text, _paymentDateController.text);
                    }else{
                      errorModel = await invoiceService.createInvoice(unitController.text, _paymentDateController.text);
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
                },
                child: Text(id == null ? 'save'.tr : 'update'.tr),
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
}
