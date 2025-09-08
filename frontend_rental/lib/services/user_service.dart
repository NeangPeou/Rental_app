import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/models/error.dart';
import 'package:frontend_rental/models/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/property_controller.dart';
import '../controller/user_contoller.dart';
import '../screens/authenticate/login.dart';
import '../shared/message_dialog.dart';
import '../utils/helper.dart';

class UserService{
  Future<List<UserModel>> fetchRenters(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return [];
      }

      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        MessageDialog.showMessage('information'.tr, 'API URL not configured', context);
        return [];
      }

      final response = await http.get(
        Uri.parse('$apiUrl/api/renters'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((renterJson) => UserModel.fromJson(renterJson)).toList();
      } else {
        return [];
      }
    } catch (e) {
      MessageDialog.showMessage('information'.tr, e.toString(), context);
      return [];
    }
  }

  Future<ErrorModel> createRenter(BuildContext context, UserModel userModel) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, message: "Unauthorized");
      }

      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        return ErrorModel(isError: true, message: "API URL not configured");
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
        'gender': userModel.gender,
        'deviceName': deviceName,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/api/create-renter'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<PropertyController>().addRenter(jsonResponse);
        return ErrorModel(isError: false, message: "Renter created successfully");
      } else {
        return ErrorModel(
          isError: true,
          message: jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('message')
              ? jsonResponse['message']
              : "Failed to create renter",
        );
      }
    } catch (e) {
      return ErrorModel(isError: true, message: e.toString());
    }
  }

  Future<ErrorModel> updateRenter(BuildContext context, int id, UserModel userModel) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, message: "Unauthorized");
      }

      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        return ErrorModel(isError: true, message: "API URL not configured");
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
        'id': userModel.id,
        'username': userModel.userName,
        'password': userModel.password,
        'phoneNumber': userModel.phoneNumber,
        'passport': userModel.passport,
        'idCard': userModel.idCard,
        'address': userModel.address,
        'gender': userModel.gender,
        'deviceName': deviceName,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/api/update-renter/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<PropertyController>().updateRenter(jsonResponse);
        return ErrorModel(isError: false, message: "Renter updated successfully");
      } else {
        return ErrorModel(
          isError: true,
          message: jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('message')
              ? jsonResponse['message']
              : "Failed to update renter",
        );
      }
    } catch (e) {
      return ErrorModel(isError: true, message: e.toString());
    }
  }

  Future<ErrorModel> deleteRenter(BuildContext context, String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, message: "Unauthorized");
      }

      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        return ErrorModel(isError: true, message: "API URL not configured");
      }

      final response = await http.delete(
        Uri.parse('$apiUrl/api/delete-renter/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final jsonResponse = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        Get.find<PropertyController>().removeRenter(id);
        return ErrorModel(isError: false, message: "Renter deleted successfully");
      } else {
        String errorMessage = jsonResponse != null && jsonResponse['message'] != null ? jsonResponse['message']: "renter_cannot_delete_being_used_in_lease".tr;
        Helper.errorSnackbar(errorMessage); 
        return ErrorModel(isError: true, message: errorMessage);
      }
    } catch (e) {
      Helper.errorSnackbar(e.toString());
      return ErrorModel(isError: true, message: e.toString());
    }
  }

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
      MessageDialog.showMessage('information'.tr, e.toString(), context);
      return [];
    }
  }

  Future<void> createOwner(BuildContext context, UserModel userModel) async {
    try {
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
        'gender': userModel.gender,
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
      }
    } catch (e) {
      MessageDialog.showMessage('information'.tr, e.toString(), context);
    }
  }

  Future<void> updateOwner(BuildContext context, int id, UserModel userModel) async {
    try {
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
        'id': userModel.id,
        'username': userModel.userName,
        'password': userModel.password,
        'phoneNumber': userModel.phoneNumber,
        'passport': userModel.passport,
        'idCard': userModel.idCard,
        'address': userModel.address,
        'gender': userModel.gender,
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
      }
    } catch (e) {
      MessageDialog.showMessage('information'.tr, e.toString(), context);
    }
  }

  Future<void> deleteOwner(BuildContext context, String id) async {
    try {
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
      }
    } catch (e) {
      MessageDialog.showMessage('information'.tr, e.toString(), context);
    }
  }

  Future<ErrorModel> updateProfile(BuildContext context, UserModel userModel) async {
    try {
      Helper.showLoadingDialog(context);
      UserController userController = Get.put(UserController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        Get.offAll(() => Login());
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }

      final payload = {
        'id': userModel.id,
        'username': userModel.userName,
        'password': userModel.password,
        'phoneNumber': userModel.phoneNumber,
        'passport': userModel.passport,
        'idCard': userModel.idCard,
        'address': userModel.address,
        'gender': userModel.gender,
      };

      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/api/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );
      Map<String, dynamic>? res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        userController.setCurrentUser(res!);
        return ErrorModel(isError: false, code: 'Success', message: 'Profile updated successfully');
      }else if(res is Map<String, dynamic> && res['detail'] == 'Username already taken'){
        MessageDialog.showMessage('information'.tr, 'name_already_exists'.tr, context);
        return ErrorModel(isError: true, code: 'information', message: 'name_already_exists');
      }else{
        throw Exception('Update failed');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information', message: 'Update failed');
    } finally{
      Helper.closeLoadingDialog(context);
    }
  }

  Future<ErrorModel> updatePassword(BuildContext context, int id, String newPassController) async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      Map<String, dynamic> deviceInfo = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo = {
          'Model': androidInfo.model,
          'Version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo = {
          'DeviceName': iosInfo.name,
          'Model': iosInfo.model,
          'Version': iosInfo.systemVersion,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceInfo = {
          'Model': windowsInfo.computerName,
          'Version': windowsInfo.csdVersion,
        };
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        deviceInfo = {
          'Model': macInfo.model,
          'Version': macInfo.osRelease,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceInfo = {
          'Name': linuxInfo.name,
          'Version': linuxInfo.version,
        };
      } else {
        deviceInfo = {
          'Platform': 'Unknown',
          'Error': 'Unsupported platform',
        };
      }
      Helper.showLoadingDialog(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');
      if (accessToken == null || accessToken.isEmpty) {
        Get.offAll(() => Login());
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }

      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/api/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'id': id,
          'newPassword': newPassController,
          'deviceInfo': jsonEncode(deviceInfo),
        }),
      );
      Map<String, dynamic>? res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (res!.containsKey('accessToken')) {
          await prefs.setString('x-auth-token', res['accessToken']);
        }
        return ErrorModel(isError: false, code: 'Success', message: 'Password changed successfully');
      } else{
        throw Exception('Update failed');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information'.tr, message: 'Update failed');
    }finally{
      Helper.closeLoadingDialog(context);
    }
  }
}