import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/systemlog_controller.dart';
import 'package:frontend_admin/models/systemlog_model.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class SystemLogs extends StatelessWidget {
  const SystemLogs({super.key});

  Icon _getLogIcon(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return const Icon(Icons.info);
      case 'warning':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'error':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.info_outline);
    }
  }



  @override
  Widget build(BuildContext context) {
    final SystemLogController controller = Get.put(SystemLogController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadLogs(context);
    });

    return Scaffold(
      appBar: Helper.sampleAppBar("systemLog".tr, context, null),
      body: SafeArea(
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
              ),
              child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.logs.isEmpty
              ? const Center(child: Text('No logs available'))
              : ListView.builder(
                itemCount: controller.logs.length,
                itemBuilder: (context, index) {
                  final SystemLogModel log = controller.logs[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: _getLogIcon(log.logType),
                      title: Text(
                        log.message,
                      ),
                      subtitle: Text(log.createdAt),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
