import 'package:flutter/material.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:frontend_admin/services/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final _userController = TextEditingController();
    final _passController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/city.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White container with form
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Sign In Account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3062D3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildInputField(
                    label: 'User',
                    textController: _userController,
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(passController: _passController),
                  const SizedBox(height: 16),

                  // Remember me & Forgot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          const Text("Remember Password"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF3062D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        ErrorModel errorModel = await _auth.login(
                          _userController.text.trim(),
                          _passController.text.trim(),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Don't have an account? "),
                      Text(
                        "Create Account",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController textController,
  }) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController passController}) {
    return TextField(
      controller: passController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
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
