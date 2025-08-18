import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final UserController controller = Get.put(UserController());
  late String title;
  final RxBool _obscurePassword = true.obs;

  @override
  void initState() {
    super.initState();
    title = Get.arguments ?? "";
  }

  Widget buildTextField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextField(
                  label: ('Username'.tr),
                  validator: (v) => v!.isEmpty ? 'Enter username' : null,
                  onChanged: (v) => controller.username = v,
                ),
                Obx(() => buildTextField(
                  label: ('Password'.tr),
                  obscureText: _obscurePassword.value,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter password';
                    if (v.length < 3) return 'Password must be at least 3 characters';
                    return null;
                  },
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
                buildTextField(
                  label: ('PhoneNumber'.tr),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter phone number';
                    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(v)) return 'Invalid phone number';
                    return null;
                  },
                  onChanged: (v) => controller.phoneNumber = v,
                ),
                buildTextField(
                  label: ('Passport'.tr),
                  onChanged: (v) => controller.passport = v,
                ),
                buildTextField(
                  label: ('IDCard'.tr),
                  onChanged: (v) => controller.idCard = v,
                ),
                buildTextField(
                  label: ('Address'.tr),
                  onChanged: (v) => controller.address = v,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await controller.createOwner();
                          if (!Get.isSnackbarOpen) {
                            Get.back();
                          }
                        }
                      },
                      child: Text('save'.tr),
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