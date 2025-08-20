import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final RxList<Map<String, dynamic>> owners = <Map<String, dynamic>>[].obs;
  RxList<UserModel> ownerList = <UserModel>[].obs;
  final UserService _userService = UserService();

  Future<void> loadOwners(BuildContext context) async {
    final owners = await _userService.fetchOwners(context);
    ownerList.value = owners;
  }
}