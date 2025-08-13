import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[
    {
      'title': 'New message from John',
      'time': '2 mins ago',
      'isUnread': true,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Pov',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Rathana',
      'time': '1 hour ago',
      'isUnread': true,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Seng',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Chetra',
      'time': '1 hour ago',
      'isUnread': true,
      'icon': Icons.message,
    },
      {
      'title': 'New message from Sela',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
    {
      'title': 'New message from John',
      'time': '2 mins ago',
      'isUnread': true,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Pov',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Rathana',
      'time': '1 hour ago',
      'isUnread': true,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Seng',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
    {
      'title': 'New message from Chetra',
      'time': '1 hour ago',
      'isUnread': true,
      'icon': Icons.message,
    },
      {
      'title': 'New message from Sela',
      'time': '1 hour ago',
      'isUnread': false,
      'icon': Icons.message,
    },
  ].obs;

  void markAsRead(int index) {
    var notif = notifications[index];
    if (notif['isUnread'] == true) {
      notifications[index] = {
        ...notif,
        'isUnread': false,
      };
    }
  }
}
