import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/systemlog_model.dart';
import '../services/systemlog_service.dart';

class SystemLogController extends GetxController {
  final RxList<SystemLogModel> logs = <SystemLogModel>[].obs;
  RxBool isLoading = false.obs;
  final SystemLogService _systemLogService = SystemLogService();

  @override
  void onInit() {
    super.onInit();
    loadLogs(Get.context!);
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
