import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/user_contoller.dart';
import '../../../models/user_model.dart';
import '../../../utils/helper.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final UserController userController = Get.put(UserController());
  final _formKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  late String title;
  int? id;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passportCtrl = TextEditingController();
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    title = Get.arguments['title'] ?? "";

    if (userController.currentUser.isNotEmpty) {
      final userInfo = userController.currentUser;

      id = userInfo['id'] ?? '';
      if (id != null) {
        usernameCtrl.text = userInfo['userName'];
        phoneCtrl.text = userInfo['phoneNumber'];
        passportCtrl.text = userInfo['passport'] ?? '';
        idCardCtrl.text = userInfo['idCard'] ?? '';
        addressCtrl.text = userInfo['address'] ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar(title, context, null),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondaryContainer,
                        width: 1
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Get.theme.cardColor,
                      child: Icon(
                        Icons.person,
                        size: 55,
                      ),
                    ),
                  ),
                ),
                Text('account_information'.tr, style: Get.textTheme.bodyMedium),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabeledInput(
                        label: 'Username'.tr,
                        hintText: 'enter_username'.tr,
                        controller: usernameCtrl,
                        isRequired: true,
                        validator: (v) => v!.isEmpty ? 'enter_username'.tr : null,
                      ),
                      const Divider(height: 0),
                      buildLabeledInput(
                        label: 'PhoneNumber'.tr,
                        hintText: 'enter_phone_number'.tr,
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'enter_phone_number'.tr;
                          if (!RegExp(r'^\+?\d{8,15}$').hasMatch(v)) return 'Invalid_phone_number'.tr;
                          return null;
                        },
                      ),
                      const Divider(height: 0),
                      buildLabeledInput(
                        label: 'Passport'.tr,
                        hintText: 'Passport'.tr,
                        controller: passportCtrl,
                      ),
                      const Divider(height: 0),
                      buildLabeledInput(
                        label: 'IDCard'.tr,
                        hintText: 'IDCard'.tr,
                        controller: idCardCtrl,
                      ),
                      const Divider(height: 0),
                      buildLabeledInput(
                        label: 'Address'.tr,
                        hintText: 'Address'.tr,
                        controller: addressCtrl,
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: Get.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                              );
                              // await _userService.updateOwner(context, id!, userModel);
                              Helper.closeLoadingDialog(context);
                              Get.back();
                            }
                          },
                          child: Text(id == null ? 'save'.tr : 'update'.tr),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Text('change_password'.tr, style: Get.textTheme.bodyMedium),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('Password'.tr, style: Get.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right),
                    onTap: (){
                      changePasswordBottomSheet();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void changePasswordBottomSheet() {
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;
    Get.bottomSheet(
      SafeArea(
        bottom: false,
        maintainBottomViewPadding: true,
        child: StatefulBuilder(
          builder: (context, setState){
            return Container(
              height: Get.height * .7,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 15),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formPasswordKey,
                        child: Column(
                          children: [
                            Text('update_your_password'.tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            SizedBox(height: 10),
                            Text('enter_passwords_instruction'.tr, style: Get.textTheme.bodyMedium, textAlign: TextAlign.center),
                            const SizedBox(height: 30),

                            Helper.sampleTextField(
                              context: context,
                              controller: _currentPassController,
                              labelText: 'current_password'.tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_current_password'.tr;
                                return null;
                              },
                              obscureText: _obscureCurrentPassword,
                              onChanged: (_) {
                                if (_passwordError != null) {
                                  setState(() {
                                    _passwordError = null;
                                  });
                                }
                              },
                              suffixIcon: IconButton(
                                icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _obscureCurrentPassword = !_obscureCurrentPassword;
                                  });
                                },
                              ),
                              prefixIcon: Icon(Icons.lock_outline),
                              passwordType: true,
                              isRequired: true,
                            ),

                            const SizedBox(height: 20),

                            /// New Password Field
                            Helper.sampleTextField(
                              context: context,
                              controller: _newPassController,
                              labelText: 'new_password'.tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_new_password'.tr;
                                return null;
                              },
                              obscureText: _obscureNewPassword,
                              onChanged: (_) {},
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                              prefixIcon: Icon(Icons.lock_open),
                              passwordType: true,
                              isRequired: true,
                            ),

                            const SizedBox(height: 20),

                            /// Confirm New Password Field
                            Helper.sampleTextField(
                              context: context,
                              controller: _confirmPassController,
                              labelText: 'confirm_password'.tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_confirm_password'.tr;
                                if (value != _newPassController.text) return 'passwords_do_not_match'.tr;
                                return null;
                              },
                              obscureText: _obscureConfirmPassword,
                              onChanged: (_) {},
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              prefixIcon: Icon(Icons.lock),
                              passwordType: true,
                              isRequired: true,
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: Get.height,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (_formPasswordKey.currentState?.validate() ?? false) {
                                      print('Valid form. Change password...');
                                    } else {
                                      print('Form not valid');
                                    }
                                  },
                                  child: Text('change_password'.tr)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        ),
      ),
      isScrollControlled: false,
    );
  }
}

Widget buildLabeledInput({
  required String label,
  required String hintText,
  required TextEditingController controller,
  bool isRequired = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(label, style: Get.textTheme.bodyMedium),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              style: Get.textTheme.bodySmall,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: hintText,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Get.theme.cardColor,
                    radius: 10,
                    child: const Icon(Icons.clear_rounded, size: 15),
                  ),
                  onPressed: () => controller.clear(),
                )
              ),
              validator: (v) {
                if (isRequired && (v == null || v.isEmpty)) {
                  return '$label ${'is_required'.tr}';
                }
                if (validator != null) return validator(v);
                return null;
              },
            ),
          ),
        ],
      ),
    ],
  );
}