import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<ErrorModel> login(BuildContext context, String username, String password) async {
    try {
      Helper.showLoadingDialog(context);
      Response res = await post(
        Uri.parse('${dotenv.env['API_URL']}/api/login'),
        body: jsonEncode({'username': username, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      String token = jsonDecode(res.body)['access_token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', token);
      ErrorModel errorModel = ErrorModel(isError: false, code: 'Information');
      // ignore: use_build_context_synchronously
      Helper.closeLoadingDialog(context);
      return errorModel;
    } catch (e) {
      ErrorModel errorModel = ErrorModel(
        isError: true,
        code: 'Information',
        message: e.toString(),
      );
      // ignore: use_build_context_synchronously
      Helper.closeLoadingDialog(context);
      return errorModel;
    }
  }
}
