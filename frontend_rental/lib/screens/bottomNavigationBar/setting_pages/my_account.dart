import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rental/models/error.dart';
import 'package:frontend_rental/services/user_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/user_contoller.dart';
import '../../../models/user_model.dart';
import '../../../shared/message_dialog.dart';
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
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final List<String> genderOptions = ['Male', 'Female'];
  int selectedIndex = 0;
  final UserService _userService = UserService();
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
        phoneCtrl.text = userInfo['phoneNumber'] ?? '';
        passportCtrl.text = userInfo['passport'] ?? '';
        idCardCtrl.text = userInfo['idCard'] ?? '';
        addressCtrl.text = userInfo['address'] ?? '';
        final gender = userInfo['gender']?.toString();
        selectedIndex = (gender != null && genderOptions.contains(gender)) ? genderOptions.indexOf(gender) : 0;
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
                  child: GestureDetector(
                    onTap: () => _showCupertinoImagePicker(context),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.secondaryContainer,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Get.theme.cardColor,
                            backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                            child: _imageFile == null ? const Icon(Icons.person, size: 60) : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
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
                      const Divider(height: 0),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _showGenderPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text('gender'.tr, style: Get.textTheme.bodyMedium),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(genderOptions[selectedIndex], style: Get.textTheme.bodySmall),
                                      const SizedBox(width: 22),
                                      const Icon(CupertinoIcons.chevron_down, size: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              UserModel userModel = UserModel(
                                id: id?.toString(),
                                userName: usernameCtrl.text,
                                password: passwordCtrl.text,
                                phoneNumber: phoneCtrl.text,
                                passport: passportCtrl.text,
                                idCard: idCardCtrl.text,
                                address: addressCtrl.text,
                                gender: genderOptions[selectedIndex],
                              );
                              ErrorModel error = await _userService.updateProfile(context, userModel);
                              if(error.isError == true && error.message == 'name_already_exists') {
                                MessageDialog.showMessage('information'.tr, 'name_already_exists'.tr, context);
                              }else if (error.isError == false){
                                Get.showSnackbar(
                                  GetSnackBar(
                                    messageText: const SizedBox.shrink(),
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Get.theme.cardColor,
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
                                        Text('updated_successfully'.tr, style: Get.textTheme.titleMedium),
                                      ],
                                    ),
                                  ),
                                );
                              }else {
                                MessageDialog.showMessage('information'.tr, 'update_failed'.tr, context);
                              }
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

  void _showCupertinoImagePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text("select_profile_photo".tr),
        actions: [
          CupertinoActionSheetAction(
            child: Text("camera".tr),
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: Text("gallery".tr),
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void changePasswordBottomSheet() {
    _newPassController.clear();
    _confirmPassController.clear();
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

                            const SizedBox(height: 10),

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

                            const SizedBox(height: 10),

                            SizedBox(
                              width: Get.height,
                              child: ElevatedButton(
                                  onPressed: ()async {
                                    if (_formPasswordKey.currentState!.validate()) {
                                      ErrorModel error = await _userService.updatePassword(context, id!, _newPassController.text.trim());
                                      if (error.isError == false){
                                        Get.back();
                                        Get.showSnackbar(
                                          GetSnackBar(
                                            messageText: const SizedBox.shrink(), // Hide message
                                            snackPosition: SnackPosition.TOP,
                                            backgroundColor: Get.theme.cardColor,
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
                                                Text('updated_successfully'.tr, style: Get.textTheme.titleMedium),
                                              ],
                                            ),
                                          ),
                                        );
                                      }else {
                                        MessageDialog.showMessage('information'.tr, 'update_failed'.tr, context);
                                      }
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

  void _showGenderPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Get.theme.cardColor,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Done'),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 30,
                scrollController:
                FixedExtentScrollController(initialItem: selectedIndex),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: genderOptions.map((gender) => Text(gender)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildLabeledInput({required String label, required String hintText, required TextEditingController controller, bool isRequired = false, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(label, style: Get.textTheme.bodyMedium),
          ),
          Expanded(
            child: FormField<String>(
              initialValue: controller.text,
              validator: (v) {
                if (isRequired && (v == null || v.isEmpty)) {
                  return '$label ${'is_required'.tr}';
                }
                if (validator != null) return validator(v);
                return null;
              },
              builder: (FormFieldState<String> state) {
                final bool showError = isRequired && state.hasError;

                return TextFormField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: showError ? Colors.red.withOpacity(0.7) : null,
                  ),
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: Get.textTheme.bodySmall?.copyWith(
                      color: showError ? Colors.red.withOpacity(0.7) : Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    suffixIcon: IconButton(
                      icon: CircleAvatar(
                        backgroundColor: Get.theme.cardColor,
                        radius: 10,
                        child: const Icon(Icons.clear_rounded, size: 15),
                      ),
                      onPressed: () {
                        controller.clear();
                        state.didChange('');
                      },
                    ),
                  ),
                  onChanged: (value) {
                    state.didChange(value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
}
