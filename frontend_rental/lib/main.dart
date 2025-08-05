import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(RentalApp());

class RentalApp extends StatelessWidget {
  final codeCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  RentalApp({super.key});

  Future<void> register() async {
    await http.post(
      Uri.parse("http://127.0.0.1:8000/auth/rental/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code": codeCtrl.text,
        "username": userCtrl.text,
        "password": passCtrl.text,
      }),
    );
  }

  Future<void> login() async {
    await http.post(
      Uri.parse("http://127.0.0.1:8000/auth/rental/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code": codeCtrl.text,
        "username": userCtrl.text,
        "password": passCtrl.text,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Rental Register/Login")),
        body: Column(
          children: [
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(labelText: "Code"),
            ),
            TextField(
              controller: userCtrl,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passCtrl,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            Row(
              children: [
                ElevatedButton(onPressed: register, child: Text("Register")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: login, child: Text("Login")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
