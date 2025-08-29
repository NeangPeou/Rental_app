import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/controller/user_contoller.dart';
import 'package:frontend_rental/models/error.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthService {
  static Future<void> login(BuildContext context, String username, String password) async {
    try {
      UserController userController = Get.put(UserController());
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
      final res = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/login'),
        body: jsonEncode({
          'username': username, 
          'password': password,
          'deviceName': deviceName,
          'userAgent': userAgent,
          'isAdmin': false
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      Map<String, dynamic>? response = jsonDecode(res.body);
      if(res.statusCode == 404){
        throw Exception(response!['detail'] ?? 'Failed to login');
      } else if(res.statusCode == 200){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('x-auth-token', response!['accessToken']);
        await prefs.setBool('isOwner', true);

        userController.setCurrentUser(response);
        return;
      }

      throw Exception(response!['detail'] ?? 'Failed to login');
    } catch (e) {
      rethrow;
    }
  }

  Future<ErrorModel> getUserData(BuildContext context) async {
    UserController userController = Get.put(UserController());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    try {
      final res = await http.post(
          Uri.parse('${dotenv.env['API_URL']}/api/tokensValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          }
      );
      if (res.statusCode == 200) {
        Map<String, dynamic>? response = jsonDecode(res.body);
        userController.setCurrentUser(response!);
        return ErrorModel(isError: false, code: 'Information', message: 'Token valid');
      } else {
        return ErrorModel(
          isError: true,
          code: 'Information',
          message: 'failed_to_login',
        );
      }
    } catch (e) {
      ErrorModel errorModel = ErrorModel(
        isError: true,
        code: 'Information',
        message: e.toString(),
      );
      Helper.closeLoadingDialog(context);
      return errorModel;
    }
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', '');
  }
}
