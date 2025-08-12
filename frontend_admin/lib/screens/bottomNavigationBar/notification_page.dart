import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/notification_controller.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications yet!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            return ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).cardColor,
                    child: Icon(
                      notif['icon'] as IconData,
                      size: 24,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  if (notif['isUnread'] as bool)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                notif['title'] as String,
                style: TextStyle(
                  fontWeight: (notif['isUnread'] as bool)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                notif['time'] as String,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              onTap: () {
                controller.markAsRead(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped: ${notif['title']}')),
                );
              },
            );
          },
        );
      }),
    );
  }
}
