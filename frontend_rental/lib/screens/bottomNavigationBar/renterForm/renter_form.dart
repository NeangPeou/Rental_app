import 'package:flutter/material.dart';
import 'package:frontend_rental/models/error.dart';
import 'package:frontend_rental/models/user_model.dart';
import 'package:frontend_rental/services/user_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';

class RenterForm extends StatefulWidget {
  const RenterForm({super.key});

  @override
  State<RenterForm> createState() => _RenterFormState();
}

class _RenterFormState extends State<RenterForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  int? id;
  final RxBool _obscurePassword = true.obs;
  final UserService _userService = UserService();

  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passportCtrl = TextEditingController();
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final RxString selectedGender = 'Male'.obs;

  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> args = Get.arguments;
      id = int.tryParse(args['id']?.toString() ?? '');
      title = id == null ? 'create'.tr : 'update'.tr;
      if (id != null) {
        usernameCtrl.text = args['userID']?.toString() ?? '';
        phoneCtrl.text = args['phoneNumber']?.toString() ?? '';
        passportCtrl.text = args['passport']?.toString() ?? '';
        idCardCtrl.text = args['idCard']?.toString() ?? '';
        addressCtrl.text = args['address']?.toString() ?? '';
        selectedGender.value =
            genderOptions.contains(args['gender']?.toString())
            ? args['gender']!
            : 'Male';
      }
    } else {
      title = 'create'.tr;
    }
  }

  Widget _buildSection({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(120),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // bigger padding
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(120),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "basicInfo".tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleTextField(
                          context: context,
                          controller: usernameCtrl,
                          labelText: ('Username'.tr),
                          validator: (v) =>
                              v!.isEmpty ? ('enter_username'.tr) : null,
                          isRequired: true,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 5),
                        Obx(
                          () => Helper.sampleTextField(
                            context: context,
                            controller: passwordCtrl,
                            labelText: ('Password'.tr),
                            obscureText: _obscurePassword.value,
                            passwordType: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return id == null ? ('enter_password'.tr) : null;
                              }
                              if (v.length <= 3) {
                                return ('Password_must_be_at_least_3_characters'.tr);
                              }
                              return null;
                            },
                            isRequired: id == null,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                _obscurePassword.value = !_obscurePassword.value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "contactInfo".tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleTextField(
                          context: context,
                          controller: phoneCtrl,
                          labelText: ('PhoneNumber'.tr),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return ('enter_phone_number'.tr);
                            }
                            if (!RegExp(r'^\+?[\d\s\-()]{8,15}$').hasMatch(v)) {
                              return ('Invalid_phone_number'.tr);
                            }
                            return null;
                          },
                          isRequired: true,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleTextField(
                          context: context,
                          controller: addressCtrl,
                          labelText: ('Address'.tr),
                          prefixIcon: const Icon(Icons.home),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "identification".tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleTextField(
                          context: context,
                          controller: passportCtrl,
                          labelText: ('Passport'.tr),
                          prefixIcon: const Icon(Icons.badge),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleTextField(
                          context: context,
                          controller: idCardCtrl,
                          labelText: ('IDCard'.tr),
                          prefixIcon: const Icon(Icons.credit_card),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "gender".tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Helper.sampleRadioGroup(
                          context: context,
                          selectedValue: selectedGender,
                          options: genderOptions,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: Get.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor.withAlpha(120),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Helper.showLoadingDialog(context);
                            UserModel userModel = UserModel(
                              id: id?.toString(),
                              userName: usernameCtrl.text,
                              password: passwordCtrl.text,
                              phoneNumber: phoneCtrl.text,
                              passport: passportCtrl.text,
                              idCard: idCardCtrl.text,
                              address: addressCtrl.text,
                              gender: selectedGender.value,
                            );
                            ErrorModel result;
                            if (id == null) {
                              result = await _userService.createRenter(
                                context,
                                userModel,
                              );
                            } else {
                              result = await _userService.updateRenter(
                                context,
                                id!,
                                userModel,
                              );
                            }
                            Helper.closeLoadingDialog(context);
                            if (result.isError == false) {
                              Get.back();
                              Helper.successSnackbar(
                                id == null
                                    ? 'created_successfully'.tr
                                    : 'updated_successfully'.tr,
                              );
                            } else {
                              String errorMessage = result.message!.toLowerCase();
                              if (errorMessage.contains('already exists')) {
                                Helper.errorSnackbar('data_already_exists'.tr);
                              } else {
                                Helper.errorSnackbar(
                                  id == null
                                      ? 'create_failed'.tr
                                      : 'update_failed'.tr,
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          id == null ? 'save'.tr : 'update'.tr,
                          style: theme.textTheme.titleMedium
                        ),
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
