import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final UserController controller = Get.find<UserController>();
  late String title;
  int? id;
  final RxBool _obscurePassword = true.obs;

  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passportCtrl = TextEditingController();
  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> args = Get.arguments;
      title = args['title']?.toString() ?? 'Update Owner';
      id = int.tryParse(args['id']);
      if (id != null) {
        usernameCtrl.text = args['userID']?.toString() ?? '';
        phoneCtrl.text = args['phoneNumber']?.toString() ?? '';
        passportCtrl.text = args['passport']?.toString() ?? '';
        idCardCtrl.text = args['idCard']?.toString() ?? '';
        addressCtrl.text = args['address']?.toString() ?? '';
        controller.username = usernameCtrl.text;
        controller.phoneNumber = phoneCtrl.text;
        controller.passport = passportCtrl.text;
        controller.idCard = idCardCtrl.text;
        controller.address = addressCtrl.text;
      }
    } else {
      title = Get.arguments?.toString() ?? 'Create Owner';
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
            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
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
                  onChanged: (v) => controller.username = v,
                ),
                const SizedBox(height: 10),
                Obx(() => Helper.sampleTextField(
                  context: context,
                  controller: passwordCtrl,
                  labelText: ('Password'.tr),
                  obscureText: _obscurePassword.value,
                  passwordType: true,
                  validator: id == null
                      ? (v) {
                          if (v == null || v.isEmpty) return ('enter_password'.tr);
                          if (v.length < 3) {
                            return ('Password_must_be_at_least_characters'.tr);
                          }
                          return null;
                        }
                      : null,
                  isRequired: id == null,
                  onChanged: (v) => controller.password = v,
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
                    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(v)) {
                      return ('Invalid_phone_number'.tr);
                    }
                    return null;
                  },
                  isRequired: true,
                  onChanged: (v) => controller.phoneNumber = v,
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: passportCtrl,
                  labelText: ('Passport'.tr),
                  validator: (v) => null,
                  onChanged: (v) => controller.passport = v,
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: idCardCtrl,
                  labelText: ('IDCard'.tr),
                  validator: (v) => null,
                  onChanged: (v) => controller.idCard = v,
                ),
                const SizedBox(height: 10),
                Helper.sampleTextField(
                  context: context,
                  controller: addressCtrl,
                  labelText: ('Address'.tr),
                  validator: (v) => null,
                  onChanged: (v) => controller.address = v,
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
                          if (id == null) {
                            Helper.showLoadingDialog(context);
                            await controller.createOwner();
                            if(!Get.isSnackbarOpen || Get.isSnackbarOpen && Get.currentRoute != '/Home'){
                              Helper.closeLoadingDialog(context);
                              Get.off(() => const Home(), arguments: {'index': 0});
                            }
                          } else {
                            Helper.showLoadingDialog(context);
                            await controller.updateOwner(id!);
                            if(!Get.isSnackbarOpen || Get.isSnackbarOpen && Get.currentRoute != '/Home'){
                              Helper.closeLoadingDialog(context);
                              Get.off(() => const Home(), arguments: {'index': 0});
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