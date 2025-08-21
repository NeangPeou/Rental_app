import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/systemlog_model.dart';
import '../services/systemlog_service.dart';

class SystemLogController extends GetxController {
  final RxList<SystemLogModel> logs = <SystemLogModel>[].obs;
  WebSocketChannel? channel;
  RxBool isLoading = false.obs;
  final SystemLogService _systemLogService = SystemLogService();

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
    channel?.sink.close();
    super.dispose();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('${dotenv.env['SOCKET_URL']}/api/ws/system-logs'),
    );
    channel?.sink.add(jsonEncode({
      "action": "init",
    }));
    channel?.stream.listen((message) {
      final decode = jsonDecode(message);
      String action = decode['action'];

      switch (action) {
        case 'create':
          handleCreate(decode['data']);
          break;
        case 'init':
          handleInit(decode['data']);
          break;
      }
    }, onError: (error) {
      isLoading.value = false;
    });
  }

  void handleInit(List<dynamic> logJsonList) {
    final logs = logJsonList.map((json) => SystemLogModel.fromJson(json)).toList();
    this.logs.assignAll(logs);
  }

  void handleCreate(dynamic newLogJson) {
    final newLog = SystemLogModel.fromJson(newLogJson);
    logs.add(newLog);
  }

  Future<void> loadLogs(BuildContext context) async {
    isLoading.value = true;
    try {
      final fetchedLogs = await _systemLogService.fetchSystemLogs(context);
      logs.assignAll(fetchedLogs);
    } finally {
      isLoading.value = false;
    }
  }
}