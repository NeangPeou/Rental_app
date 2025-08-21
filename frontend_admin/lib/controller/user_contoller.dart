import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final RxList<Map<String, dynamic>> owners = <Map<String, dynamic>>[].obs;
  RxList<UserModel> ownerList = <UserModel>[].obs;
  WebSocketChannel? channel;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    connectWebSocket();
  }

  @override
  void onClose() {
    channel?.sink.close();
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    channel?.sink.close();
  }

  void connectWebSocket() {
    isLoading.value = true;
    channel = WebSocketChannel.connect(
      Uri.parse('${dotenv.env['SOCKET_URL']}/api/ws/owners'),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      channel?.sink.add(jsonEncode({
        "action": "init",
      }));
    });
    channel?.stream.listen((message) {
      final decode = jsonDecode(message);
      String action = decode['action'];

      switch (action) {
        case 'create':
          handleCreate(decode['data']);
          break;
        case 'update':
          handleUpdate(decode['id'], decode['data']);
          break;
        case 'delete':
          handleDelete(decode['id']);
          break;
        case 'init':
          handleInit(decode['data']);
          break;
      }
    });
  }

  void handleInit(List<dynamic> ownerJsonList) {
    final owners = ownerJsonList.map((json) => UserModel.fromJson(json)).toList();
    ownerList.assignAll(owners);
    isLoading.value = false;
  }

  void handleCreate(dynamic newOwnerJson) {
    final newOwner = UserModel.fromJson(newOwnerJson);
    if (!ownerList.any((owner) => owner.id == newOwner.id)) {
      ownerList.insert(0, newOwner);
    }
  }

  void handleUpdate(String id, dynamic updatedOwnerJson) {
    final index = ownerList.indexWhere((owner) => owner.id == id);
    if (index != -1) {
      ownerList[index] = UserModel.fromJson(updatedOwnerJson);
      ownerList.refresh();
    }
  }

  void handleDelete(String id) {
    ownerList.removeWhere((owner) => owner.id == id);
  }
}