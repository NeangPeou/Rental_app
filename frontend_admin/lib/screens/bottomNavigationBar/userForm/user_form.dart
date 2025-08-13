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
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    label: 'User ID',
                    validator: (v) => v!.isEmpty ? 'Enter User ID' : null,
                    onChanged: (v) => controller.userID = v,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextField(
                    label: 'Role',
                    validator: (v) => v!.isEmpty ? 'Enter role' : null,
                    onChanged: (v) => controller.role = v,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Username',
              validator: (v) => v!.isEmpty ? 'Enter username' : null,
              onChanged: (v) => controller.username = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter email';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter valid email';
                return null;
              },
              onChanged: (v) => controller.email = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
              onChanged: (v) => controller.phoneNumber = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Passport',
              onChanged: (v) => controller.passport = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'ID Card',
              onChanged: (v) => controller.idCard = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Address',
              onChanged: (v) => controller.address = v,
            ),
            SizedBox(height: 10),
            buildTextField(
              label: 'Password',
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter password';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
              onChanged: (v) => controller.password = v,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.back();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
