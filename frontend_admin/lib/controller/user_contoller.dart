import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final RxList<Map<String, dynamic>> owners = <Map<String, dynamic>>[].obs;
  RxList<UserModel> ownerList = <UserModel>[].obs;
  final UserService _userService = UserService();
  late WebSocketChannel channel;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }

  Future<void> loadOwners(BuildContext context) async {
    isLoading.value = true;
    try {
      final owners = await _userService.fetchOwners(Get.context!);
      ownerList.assignAll(owners);
    } finally {
      isLoading.value = false;
    }
  }

  void _connectWebSocket() {
    channel = WebSocketChannel.connect(
      // Uri.parse('${dotenv.env['SOCKET_URL']}/ws/owners'),
        Uri.parse('${dotenv.env['SOCKET_URL']}/ws/owners')
    );

    channel.stream.listen((message) {
      try {
        final data = json.decode(message);

        switch (data['action']) {
          case 'create':
            _handleCreate(data['data']);
            break;
          case 'update':
            _handleUpdate(data['id'], data['data']);
            break;
          case 'delete':
            _handleDelete(data['id']);
            break;
        }
      } catch (e) {
        print('Error parsing WebSocket message: $e');
      }
    }, onDone: () async {
      await Future.delayed(Duration(seconds: 5));
      _connectWebSocket();
    }, onError: (error) async {
      await Future.delayed(Duration(seconds: 5));
      _connectWebSocket();
    });
  }

  void _handleCreate(dynamic newOwnerJson) {
    final newOwner = UserModel.fromJson(newOwnerJson);
    ownerList.add(newOwner);
  }

  void _handleUpdate(int id, dynamic updatedOwnerJson) {
    final index = ownerList.indexWhere((owner) => owner.id == id);
    if (index != -1) {
      ownerList[index] = UserModel.fromJson(updatedOwnerJson);
      ownerList.refresh();
    }
  }

  void _handleDelete(int id) {
    ownerList.removeWhere((owner) => owner.id == id);
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }
}