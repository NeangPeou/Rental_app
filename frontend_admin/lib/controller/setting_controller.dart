import 'package:flutter/material.dart';
import 'package:frontend_admin/storage/storage_keys.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final box = GetStorage();

  RxnBool isDarkMode = RxnBool();
  RxDouble saturation = 1.0.obs;
  RxDouble contrast = 1.0.obs;

  @override
  void onInit() {
    super.onInit();

    if (box.hasData(StorageKeys.isDarkMode)) {
      isDarkMode.value = box.read(StorageKeys.isDarkMode);
    }

    saturation.value = box.read(StorageKeys.saturation) ?? 1.0;
    contrast.value = box.read(StorageKeys.contrast) ?? 1.0;

    // Apply theme on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = isDarkMode.value;
      Get.changeThemeMode(
        mode == null ? ThemeMode.system : (mode ? ThemeMode.dark : ThemeMode.light),
      );
    });
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    box.write('isDarkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setSaturation(double value) {
    saturation.value = value;
    box.write('saturation', value);
  }

  void resetSaturation() {
    saturation.value = 1.0;
    box.write('saturation', 1.0);
  }

  void setContrast(double value) {
    contrast.value = value;
    box.write('contrast', value);
  }

  void resetContrast() {
    contrast.value = 1.0;
    box.write('contrast', 1.0);
  }
}
