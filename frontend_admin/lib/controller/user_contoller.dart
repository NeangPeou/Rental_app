import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  String username = '';
  String password = '';
  String phoneNumber = '';
  String passport = '';
  String idCard = '';
  String address = '';
  final RxList<Map<String, dynamic>> owners = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOwners(); // Initial fetch
  }

  Future<void> createOwner() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Error', 'No admin token found. Please log in as admin.', duration: const Duration(seconds: 3));
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
        'username': username,
        'password': password,
        'phoneNumber': phoneNumber.isNotEmpty ? phoneNumber : null,
        'passport': passport.isNotEmpty ? passport : null,
        'idCard': idCard.isNotEmpty ? idCard : null,
        'address': address.isNotEmpty ? address : null,
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
        Get.snackbar('Success', 'Owner created successfully', duration: const Duration(seconds: 2));
        Get.closeAllSnackbars();
        await fetchOwners();
      } else {
        Get.snackbar('Error', 'Failed to create owner: ${response.body}', duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create owner: $e', duration: const Duration(seconds: 3));
    }
  }

  Future<void> fetchOwners({String sortBy = 'userName', String order = 'asc'}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Error', 'No admin token found. Please log in as admin.', duration: const Duration(seconds: 3));
        return;
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
        owners.value = data.map((owner) => {
          'id': owner['id']?.toString() ?? '',
          'userName': owner['userName']?.toString() ?? '',
          'phoneNumber': owner['phoneNumber']?.toString() ?? '',
          'passport': owner['passport']?.toString() ?? '',
          'idCard': owner['idCard']?.toString() ?? '',
          'address': owner['address']?.toString() ?? '',
          'status': 'Active',
          'statusColor': Colors.green,
          'image': 'assets/images/user.png',
        }).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch owners: ${response.body}', duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch owners: $e', duration: const Duration(seconds: 3));
    }
  }

  Future<void> updateOwner(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Error', 'No admin token found. Please log in as admin.', duration: const Duration(seconds: 3));
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
        if (username.isNotEmpty) 'username': username,
        if (password.isNotEmpty) 'password': password,
        if (phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
        if (passport.isNotEmpty) 'passport': passport,
        if (idCard.isNotEmpty) 'idCard': idCard,
        if (address.isNotEmpty) 'address': address,
        'deviceName': deviceName
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
        Get.snackbar('Success', 'Owner updated successfully', duration: const Duration(seconds: 2));
        Get.closeAllSnackbars();
        await fetchOwners();
      } else {
        Get.snackbar('Error', 'Failed to update owner: ${response.body}', duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update owner: $e', duration: const Duration(seconds: 3));
    }
  }

  Future<void> deleteOwner(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Error', 'No admin token found. Please log in as admin.', duration: const Duration(seconds: 3));
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
        Get.snackbar('Success', 'Owner deleted successfully', duration: const Duration(seconds: 2));
        await Future.delayed(const Duration(seconds: 1));
        Get.closeAllSnackbars();
        await fetchOwners();
      } else {
        Get.snackbar('Error', 'Failed to delete owner: ${response.body}', duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete owner: $e', duration: const Duration(seconds: 3));
    }
  }
}