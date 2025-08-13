import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthService {
  Future<ErrorModel> login(BuildContext context, String username, String password) async {
    try {
      Helper.showLoadingDialog(context);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName = '';
      String userAgent = '';
      if (Platform.isAndroid){
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        userAgent = 'Android/${androidInfo.version.release}';
      }else if(Platform.isIOS){
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.model;
        userAgent = 'iOS/${iosInfo.systemVersion}';
      }
      Response res = await post(
        Uri.parse('${dotenv.env['API_URL']}/api/login'),
        body: jsonEncode({
          'username': username, 
          'password': password,
          'deviceName': deviceName,
          'userAgent': userAgent,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Client-IP': await _getClientIP(),
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
  Future<String> _getClientIP() async {
      return 'Unknown';
  }

  Future<ErrorModel> getUserData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    try {
      Response res = await post(
          Uri.parse('${dotenv.env['API_URL']}/api/tokensValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          }
      );
      if (res.statusCode == 200) {
        // Map<String, dynamic> data = jsonDecode(res.body);
        return ErrorModel(isError: false, code: 'Information', message: 'Token valid');
      } else {
        return ErrorModel(
          isError: true,
          code: 'Information',
          message: 'Token expired or invalid',
        );
      }
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

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', '');
  }
}
