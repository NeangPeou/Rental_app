import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../controller/setting_controller.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final SettingController _settingController = Get.find();
  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if(screenName == '/' || screenName == '/Dashboard') {
      _settingController.selectedIndex.value = 0;
    } else if(screenName == '/PropertyPage') {
      _settingController.selectedIndex.value = 1;
    } else if(screenName == '/PropertyUnit') {
      _settingController.selectedIndex.value = 2;
    } else if(screenName == '/LeasePage') {
      _settingController.selectedIndex.value = 4;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is PageRoute) _sendScreenView(previousRoute);
  }
}
