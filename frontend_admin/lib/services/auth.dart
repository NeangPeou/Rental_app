import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:http/http.dart';

class AuthService {
  Future<ErrorModel> login(String username, String password) async {
    try {
      Response res = await post(
        Uri.parse('${dotenv.env['API_URL']}/auth/admin/register'),
        body: jsonEncode({'username': username, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      ErrorModel errorModel = ErrorModel(
        isError: true,
        code: 'Information',
        message: jsonDecode(res.body)['message'],
      );
      return errorModel;
    } catch (e) {
      ErrorModel errorModel = ErrorModel(
        isError: true,
        code: 'Information',
        message: e.toString(),
      );
      return errorModel;
    }
  }
}
