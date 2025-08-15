import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserController extends GetxController {
  String username = '';
  String password = '';
  String phoneNumber = '';
  String passport = '';
  String idCard = '';
  String address = '';

  Future<void> createOwner() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Error', 'No admin token found. Please log in as admin.');
        return;
      }
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceName = '';
      if (Platform.isAndroid){
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      }else if(Platform.isIOS){
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.model;
      }

      final payload = {
        'username': username,
        'password': password,
        'phoneNumber': phoneNumber,
        'passport': passport,
        'idCard': idCard,
        'address': address,
        'deviceName': deviceName
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
        Get.snackbar('Success', 'Owner created successfully');
      } else {
        Get.snackbar('Error', 'Failed to create owner: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create owner: $e');
    }
  }
}