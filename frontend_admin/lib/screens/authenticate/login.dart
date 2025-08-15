import 'package:flutter/material.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:frontend_admin/services/auth.dart';
import 'package:frontend_admin/shared/message_dialog.dart';
import 'package:frontend_admin/utils/helper.dart';
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
  final AuthService _auth = AuthService();

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
                          child: Text("Sign In Account", style: Get.textTheme.titleMedium?.copyWith(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 30),

                        Helper.sampleTextField(
                          context: context,
                          controller: _userController,
                          labelText: 'Username',
                          validator: (value) => value == null || value.isEmpty ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 16),

                        Helper.sampleTextField(
                          context: context,
                          controller: _passController,
                          labelText: 'Password',
                          validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          passwordType: true,
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
                                  const Text("Remember"),
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
                                child: const Text("Forgot Password", style: TextStyle(color: Colors.blue)),
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
                                ErrorModel errorModel = await _auth.login(context, _userController.text.trim(), _passController.text.trim());
                                if (errorModel.isError) {
                                  // ignore: use_build_context_synchronously
                                  MessageDialog.showMessage(errorModel.code.toString(), errorModel.message.toString(), context);
                                } else {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                }
                              }
                            },
                            child: Text("Sign In", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Divider
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("Sign up with"),
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
                          children: const [
                            Text("Don't have an account? "),
                            Text("Create Account", style: TextStyle(color: Colors.blue)),
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
