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
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withAlpha(100),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              child: _getLogIcon(log.logType),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.createdAt,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              log.logType.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
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
