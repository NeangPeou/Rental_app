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

  final List<String> genderOptions = [
    'Male',
    'Female',
  ];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> args = Get.arguments;
      // title = args['title']?.toString() ?? '';
      id = int.tryParse(args['id']?.toString() ?? '');
      title = id == null ? 'create'.tr : 'update'.tr;
      if (id != null) {
        usernameCtrl.text = args['userID']?.toString() ?? '';
        phoneCtrl.text = args['phoneNumber']?.toString() ?? '';
        passportCtrl.text = args['passport']?.toString() ?? '';
        idCardCtrl.text = args['idCard']?.toString() ?? '';
        addressCtrl.text = args['address']?.toString() ?? '';
        selectedGender.value = genderOptions.contains(args['gender']?.toString())
            ? args['gender']!
            : 'Male';
      }
    } else {
      title = 'create'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(100),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Helper.sampleTextField(
                  context: context,
                  controller: usernameCtrl,
                  labelText: ('Username'.tr),
                  validator: (v) => v!.isEmpty ? ('enter_username'.tr) : null,
                  isRequired: true,
                  onChanged: (v) => usernameCtrl.text = v,
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 10),
                Obx(() => Helper.sampleTextField(
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
                      onChanged: (v) => passwordCtrl.text = v,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          _obscurePassword.value = !_obscurePassword.value;
                        },
                      ),
                    )),
                const SizedBox(height: 10),
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
                  onChanged: (v) => phoneCtrl.text = v,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: passportCtrl,
                  labelText: ('Passport'.tr),
                  validator: (v) => null,
                  onChanged: (v) => passportCtrl.text = v,
                  prefixIcon: const Icon(Icons.badge),
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: idCardCtrl,
                  labelText: ('IDCard'.tr),
                  validator: (v) => null,
                  onChanged: (v) => idCardCtrl.text = v,
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: addressCtrl,
                  labelText: ('Address'.tr),
                  validator: (v) => null,
                  onChanged: (v) => addressCtrl.text = v,
                  prefixIcon: const Icon(Icons.home),
                ),
                const SizedBox(height: 10),
                Helper.sampleRadioGroup(
                  context: context,
                  selectedValue: selectedGender,
                  options: genderOptions,
                  labelText: 'gender'.tr,
                  prefixIcon: const Icon(Icons.people_alt_outlined),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.closeAllSnackbars();
                        Get.back();
                      },
                      child: Text('cancel'.tr),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                            result = await _userService.createRenter(context, userModel);
                          } else {
                            result = await _userService.updateRenter(context, id!, userModel);
                          }
                          Helper.closeLoadingDialog(context);
                          if (result.isError == false) {
                            Get.back();
                            Helper.successSnackbar(id == null ? 'created_successfully'.tr : 'updated_successfully'.tr);
                          } else {
                            String errorMessage = result.message!.toLowerCase();

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
