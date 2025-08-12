
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:frontend_admin/storage/storage_keys.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final box = GetStorage();

  RxnBool isDarkMode = RxnBool();
  RxDouble saturation = 1.0.obs;
  RxDouble contrast = 1.0.obs;
  Rx<Color> selectedColor = Rx<Color>(Colors.grey[850]!);
  late var isSystemDark = false;

  @override
  void onInit() {
    super.onInit();

    if (box.hasData(StorageKeys.isDarkMode)) {
      isDarkMode.value = box.read(StorageKeys.isDarkMode);
    }else{
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isSystemDark = brightness == Brightness.dark;
      isDarkMode.value = isSystemDark;
    }

    if (box.hasData(StorageKeys.selectedColor)) {
      final colorHex = box.read(StorageKeys.selectedColor);
      selectedColor.value = Color(int.parse(colorHex, radix: 16));
    }

    saturation.value = box.read(StorageKeys.saturation) ?? 1.0;
    contrast.value = box.read(StorageKeys.contrast) ?? 1.0;

    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isSystemDark = brightness == Brightness.dark;
      isDarkMode.value = isSystemDark;

      Get.changeThemeMode(isSystemDark ? ThemeMode.dark : ThemeMode.light);
      Get.changeTheme(isSystemDark ? darkTheme() : lightTheme());
    };

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
    box.write(StorageKeys.isDarkMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setSaturation(double value) {
    saturation.value = value;
    box.write(StorageKeys.saturation, value);
  }

  void resetSaturation() {
    saturation.value = 1.0;
    box.write(StorageKeys.saturation, 1.0);
  }

  void setContrast(double value) {
    contrast.value = value;
    box.write(StorageKeys.contrast, value);
  }

  void resetContrast() {
    contrast.value = 1.0;
    box.write(StorageKeys.contrast, 1.0);
  }

  void setColor(Color color) {
    selectedColor.value = color;
    // ignore: deprecated_member_use
    box.write(StorageKeys.selectedColor, color.value.toRadixString(16));

    if (box.hasData(StorageKeys.isDarkMode)) {
      Get.changeTheme(isSystemDark == true ? darkTheme(color) :lightTheme(color));
      Get.changeThemeMode(isSystemDark == true ? ThemeMode.dark : ThemeMode.light);
    }else{
      Get.changeTheme(isSystemDark == true ? darkTheme(color) : lightTheme(color));
      Get.changeThemeMode(isSystemDark == true ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void clearStorage() async {
    await box.erase();
    resetSaturation();
    resetContrast();

    Get.delete<SettingController>();

    // Create a new one
    Get.put(SettingController());
    if (box.hasData(StorageKeys.isDarkMode)) {
      isDarkMode.value = box.read(StorageKeys.isDarkMode);
    }else{
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isSystemDark = brightness == Brightness.dark;
      isDarkMode.value = isSystemDark;
    }
  }
}
