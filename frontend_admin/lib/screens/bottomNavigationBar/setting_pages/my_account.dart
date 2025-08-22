import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/user_contoller.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../utils/helper.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  int? id;
  final RxBool _obscurePassword = true.obs;
  final UserService _userService = UserService();
  final UserController userController = Get.put(UserController());

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
      appBar: Helper.sampleAppBar(title, context, null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Optional: Profile avatar placeholder
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondaryContainer,
                        width: 1
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Get.theme.cardColor,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Helper.sampleTextField(
                  context: context,
                  controller: usernameCtrl,
                  labelText: ('Username'.tr),
                  validator: (v) => v!.isEmpty ? ('enter_username'.tr) : null,
                  isRequired: true,
                ),

                const SizedBox(height: 12),

                Obx(() => Helper.sampleTextField(
                  context: context,
                  controller: passwordCtrl,
                  labelText: ('Password'.tr),
                  obscureText: _obscurePassword.value,
                  passwordType: true,
                  validator: id == null ? (v) {
                    if (v == null || v.isEmpty) return ('enter_password'.tr);
                    if (v.length < 3) {
                      return ('Password_must_be_at_least_characters'.tr);
                    }
                    return null;
                  } : null,
                  isRequired: id == null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword.value ? Icons.visibility_off : Icons.visibility, size: 20
                    ),
                    onPressed: () {
                      _obscurePassword.value = !_obscurePassword.value;
                    },
                  ),
                )),

                const SizedBox(height: 12),

                Helper.sampleTextField(
                  context: context,
                  controller: phoneCtrl,
                  labelText: ('PhoneNumber'.tr),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return ('enter_phone_number'.tr);
                    }
                    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(v)) {
                      return ('Invalid_phone_number'.tr);
                    }
                    return null;
                  },
                  isRequired: true,
                ),

                const SizedBox(height: 12),

                Helper.sampleTextField(
                  context: context,
                  controller: passportCtrl,
                  labelText: ('Passport'.tr),
                ),

                const SizedBox(height: 12),

                Helper.sampleTextField(
                  context: context,
                  controller: idCardCtrl,
                  labelText: ('IDCard'.tr),
                ),

                const SizedBox(height: 12),

                Helper.sampleTextField(
                  context: context,
                  controller: addressCtrl,
                  labelText: ('Address'.tr),
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
        ),
      ),
    );
  }
}
