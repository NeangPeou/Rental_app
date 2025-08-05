import 'package:flutter/material.dart';
import 'package:frontend_admin/screens/authenticate/login.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isLoading = true;
  String? token;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('x-auth-token');
    if (token == null || token == '') {
      prefs.setString('x-auth-token', '');
      token = '';
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(body: Center(child: Loading()))
        : (token != '' ? Home() : Login());
  }
}
