import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/websocket_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the WebSocket service controller
    final WebSocketController wsService = Get.put(WebSocketController());

    return Scaffold(
      body: Obx(() {
        // Listen to the messages from the WebSocket service
        if (wsService.messageStream.value == null) {
          return Center(
            child: Text('No messages yet!'),
          );
        }

        // Display the incoming WebSocket message
        return ListView(
          children: [
            ListTile(
              title: Text(wsService.messageStream.value ?? 'No message'),
            ),
          ],
        );
      }),
    );
  }
}
