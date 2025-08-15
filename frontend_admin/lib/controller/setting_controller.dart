import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:frontend_admin/storage/storage_keys.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final box = GetStorage();

  static const Color defaultThemeColor = Color(0xFF212121);

  RxnBool isDarkMode = RxnBool();
  RxDouble saturation = 1.0.obs;
  RxDouble contrast = 1.0.obs;
  Rx<Color> selectedColor = Rx<Color>(defaultThemeColor);
  late bool isSystemDark;
  RxDouble fontSize = 1.0.obs;
  RxString selectedLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();

    // is called whenever either changes
    everAll([contrast, saturation, fontSize], (_) => applyTheme());

    // Load saved dark mode or determine from system
    if (box.hasData(StorageKeys.isDarkMode)) {
      isDarkMode.value = box.read(StorageKeys.isDarkMode);
    } else {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isSystemDark = brightness == Brightness.dark;
      isDarkMode.value = isSystemDark;
    }

    // Load saved theme color
    if (box.hasData(StorageKeys.selectedColor)) {
      try {
        final colorHex = box.read(StorageKeys.selectedColor);
        selectedColor.value = Color(int.parse(colorHex, radix: 16));
      } catch (_) {
        selectedColor.value = defaultThemeColor;
      }
    }

    // Load saturation and contrast
    saturation.value = box.read(StorageKeys.saturation) ?? 1.0;
    contrast.value = box.read(StorageKeys.contrast) ?? 1.0;
    fontSize.value = box.read(StorageKeys.fontSize) ?? 1.0;
    selectedLanguage.value = box.read(StorageKeys.selectedLanguage) ?? 'English';

    // Listen to system brightness changes
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      final brightness = PlatformDispatcher.instance.platformBrightness;
      isSystemDark = brightness == Brightness.dark;
      isDarkMode.value = isSystemDark;
      applyTheme();
    };

    // Apply theme after build
    WidgetsBinding.instance.addPostFrameCallback((_) => applyTheme());
  }

  // Toggle light/dark mode manually
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    box.write(StorageKeys.isDarkMode, value);
    applyTheme();
  }

  // Apply saturation
  void setSaturation(double value) {
    saturation.value = value;
    box.write(StorageKeys.saturation, value);
  }

  void resetSaturation() => setSaturation(1.0);

  // Apply contrast
  void setContrast(double value) {
    contrast.value = value;
    box.write(StorageKeys.contrast, value);
  }

  void resetContrast() => setContrast(1.0);

  // Set primary theme color
  void setColor(Color color) {
    selectedColor.value = color;
    // ignore: deprecated_member_use
    box.write(StorageKeys.selectedColor, color.value.toRadixString(16).padLeft(8, '0'));
    applyTheme();
  }

  // Apply theme based on current values
  void applyTheme() {
    final dark = isDarkMode.value ?? isSystemDark;
    final color = selectedColor.value;

    Get.changeTheme(dark ? darkTheme(color) : lightTheme(color));
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  void setFontSize(double value) {
    fontSize.value = value;
    box.write(StorageKeys.fontSize, value);
    applyTheme();
  }

  void resetFontSize() => setFontSize(1.0);

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
    box.write(StorageKeys.selectedLanguage, lang);
  }

  // Clear all stored settings
  Future<void> clearStorage() async {
    await box.erase();

    // Reset in-memory state
    isDarkMode.value = null;
    isSystemDark = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    isDarkMode.value = isSystemDark;

    selectedColor.value = defaultThemeColor;
    saturation.value = 1.0;
    contrast.value = 1.0;
    fontSize.value = 1.0;
    setLanguage('English');
    Get.updateLocale(Locale('en', 'US'));

    applyTheme();
  }
}
