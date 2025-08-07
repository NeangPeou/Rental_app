import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final _box = GetStorage();

  RxBool isDarkMode = false.obs;
  RxDouble saturation = 1.0.obs;
  RxDouble contrast = 1.0.obs;

  @override
  void onInit() {
    super.onInit();

    // ✅ Load stored values or set defaults
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    saturation.value = _box.read('saturation') ?? 1.0;
    contrast.value = _box.read('contrast') ?? 1.0;

    // ✅ Apply theme on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    });
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _box.write('isDarkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setSaturation(double value) {
    saturation.value = value;
    _box.write('saturation', value);
  }

  void resetSaturation() {
    saturation.value = 1.0;
    _box.write('saturation', 1.0);
  }

  void setContrast(double value) {
    contrast.value = value;
    _box.write('contrast', value);
  }

  void resetContrast() {
    contrast.value = 1.0;
    _box.write('contrast', 1.0);
  }
}
