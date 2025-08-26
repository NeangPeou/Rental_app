import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/user_contoller.dart';
import 'package:frontend_rental/shared/message_dialog.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _passwordError;
  String? _usernameError;
  UserController userController = Get.put(UserController());

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/city.png'), fit: BoxFit.cover,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Text("sign_in_account".tr, style: Get.textTheme.titleMedium?.copyWith(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 30),

                        Helper.sampleTextField(
                          context: context,
                          controller: _userController,
                          labelText: 'username'.tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'enter_username'.tr;
                            if (_usernameError != null) return _usernameError;
                            return null;
                          },
                          onChanged: (_) {
                            if (_usernameError != null) {
                              setState(() {
                                _usernameError = null;
                              });
                            }
                          },
                          isRequired: true, 
                        ),
                        const SizedBox(height: 16),

                        Helper.sampleTextField(
                          context: context,
                          controller: _passController,
                          labelText: 'password'.tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'enter_password'.tr;
                            if (_passwordError != null) return _passwordError;
                            return null;
                          },
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() {
                                _passwordError = null;
                              });
                            }
                          },
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          passwordType: true,
                          isRequired: true, 
                        ),

                        const SizedBox(height: 10),

                        // Remember me & Forgot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value!;
                                      });
                                    },
                                  ),
                                  Text("remember".tr),
                                ],
                              ),
                            ),

                            Flexible(
                              child: TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                ),
                                child: Text("forgot_password".tr, style: TextStyle(color: Colors.blue)),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool revalidate = false;
                                try {
                                  await userController.login(context, _userController.text.trim(), _passController.text.trim());
                                  Get.offAllNamed('/home');
                                } catch (e) {
                                  String errorMsg = e.toString();

                                  if (errorMsg.contains('Invalid username')) {
                                    setState(() {
                                      _usernameError = 'invalid_username'.tr;
                                    });
                                    revalidate = true;
                                  } else if (errorMsg.contains('Invalid password')) {
                                    setState(() {
                                      _passwordError = 'invalid_password'.tr;
                                    });
                                    revalidate = true;
                                  } else {
                                    MessageDialog.showMessage('information'.tr, 'failed_to_login'.tr, context);
                                  }
                                }
                                if (revalidate) {
                                  _formKey.currentState!.validate();
                                }
                              }
                            },
                            child: Text("sign_in".tr, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("sign_up_with".tr),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Social Media Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialIcon("assets/images/facebook.png"),
                            const SizedBox(width: 16),
                            _socialIcon("assets/images/google.png"),
                            const SizedBox(width: 16),
                            _socialIcon("assets/images/microsoft.png"),
                            const SizedBox(width: 16),
                            _socialIcon("assets/images/apple.png"),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Sign up text
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text("${"dont_have_account".tr} "),
                            Text("create_account".tr, style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.transparent,
      child: Image.asset(assetPath, height: 24, width: 24),
    );
  }
}
