import 'package:frontend_rental/services/auth.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  Future<void> login(BuildContext context, String username, String password) async {
    try {
      await AuthService.login(context, username, password);
    } catch (e) {
      rethrow;
    } finally{
      Helper.closeLoadingDialog(context);
    }
  }

  void setCurrentUser(Map<String, dynamic> user) {
    currentUser.value = user;
  }
}