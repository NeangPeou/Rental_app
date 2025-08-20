import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/message_dialog.dart';

class UserService{

  Future<List<UserModel>> fetchOwners(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/owners'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((ownerJson) => UserModel.fromJson(ownerJson)).toList();
      } else {
        return [];
      }
    } catch (e) {
      MessageDialog.showMessage('Information', e.toString(), context);
      return [];
    }
  }

  Future<void> createOwner(BuildContext context, UserModel userModel) async {
    try {
      final UserController userController = Get.put(UserController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.model;
      }

      final payload = {
        'username': userModel.userName,
        'password': userModel.password,
        'phoneNumber': userModel.phoneNumber,
        'passport': userModel.passport,
        'idCard': userModel.idCard,
        'address': userModel.address,
        'deviceName': deviceName,
      };
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/create-owner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        userController.loadOwners(context);
      }
    } catch (e) {
      MessageDialog.showMessage('Information', e.toString(), context);
    }
  }

  Future<void> updateOwner(BuildContext context, int id, UserModel userModel) async {
    try {
      final UserController userController = Get.put(UserController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.model;
      }

      final payload = {
        'username': userModel.userName,
        'password': userModel.password,
        'phoneNumber': userModel.phoneNumber,
        'passport': userModel.passport,
        'idCard': userModel.idCard,
        'address': userModel.address,
        'deviceName': deviceName,
      };
      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/api/update-owner/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        userController.loadOwners(context);
      }
    } catch (e) {
      MessageDialog.showMessage('Information', e.toString(), context);
    }
  }

  Future<void> deleteOwner(BuildContext context, int id) async {
    try {
      final UserController userController = Get.put(UserController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/api/delete-owner/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        userController.loadOwners(context);
      }
    } catch (e) {
      MessageDialog.showMessage('Information', e.toString(), context);
    }
  }
}