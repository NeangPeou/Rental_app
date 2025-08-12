import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:get/get.dart';

import '../storage/storage_keys.dart';

SettingController settingController = Get.put(SettingController());

const Color firstMainThemeColor = Colors.teal;

InputDecoration textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
);

ThemeData lightTheme([Color? primaryColor]) {
  final baseTextTheme = ThemeData.light().textTheme;
  final contrastedTextTheme = applyContrastToTextTheme(
    baseTextTheme,
    Colors.black,
    settingController.contrast.value,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: adjustColorContrast(Color(0xFFF0F4F8), settingController.contrast.value),
    cardColor: settingController.box.hasData(StorageKeys.selectedColor) ? adjustColorContrast(settingController.selectedColor.value.withAlpha(70), settingController.contrast.value) : adjustColorContrast(Colors.white, settingController.contrast.value),
    textTheme: contrastedTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: settingController.box.hasData(StorageKeys.selectedColor) ? adjustColorContrast(settingController.selectedColor.value, settingController.contrast.value) : adjustColorContrast(Colors.teal, settingController.contrast.value),
        foregroundColor: adjustColorContrast(Colors.black, settingController.contrast.value),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          inherit: true,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: adjustColorContrast(firstMainThemeColor, settingController.contrast.value),
      foregroundColor: adjustColorContrast(Colors.black, settingController.contrast.value),
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: adjustColorContrast(firstMainThemeColor, settingController.contrast.value),
      selectedItemColor: adjustColorContrast(Colors.amber, settingController.contrast.value),
      unselectedItemColor: adjustColorContrast(Colors.white, settingController.contrast.value),
      elevation: 0.0,
    ),
  );
}

ThemeData darkTheme([Color? primaryColor]) {
  final baseTextTheme = ThemeData.dark().textTheme;
  final contrastedTextTheme = applyContrastToTextTheme(
    baseTextTheme,
    Colors.white,
    settingController.contrast.value,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: adjustColorContrast(Colors.grey[900]!, settingController.contrast.value),
    cardColor: settingController.box.hasData(StorageKeys.selectedColor) ? adjustColorContrast(settingController.selectedColor.value.withAlpha(70), settingController.contrast.value) : adjustColorContrast(Colors.grey[850]!, settingController.contrast.value),
    textTheme: contrastedTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: settingController.box.hasData(StorageKeys.selectedColor) ? adjustColorContrast(settingController.selectedColor.value, settingController.contrast.value) : adjustColorContrast(Colors.teal, settingController.contrast.value),
        foregroundColor: adjustColorContrast(Colors.white, settingController.contrast.value),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          inherit: true,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: adjustColorContrast(firstMainThemeColor, settingController.contrast.value),
      foregroundColor: adjustColorContrast(Colors.white, settingController.contrast.value),
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: adjustColorContrast(firstMainThemeColor, settingController.contrast.value),
      selectedItemColor: adjustColorContrast(Colors.amber, settingController.contrast.value),
      unselectedItemColor: adjustColorContrast(Colors.white, settingController.contrast.value),
      elevation: 0.0
    ),
  );
}

Color adjustColorContrast(Color color, double contrast) {
  contrast = contrast.clamp(0.5, 2.0);

  int adjust(int value) {
    final factor = (value - 128) * contrast + 128;
    return factor.clamp(0, 255).toInt();
  }

  return Color.fromARGB(
    color.alpha,
    adjust(color.red),
    adjust(color.green),
    adjust(color.blue),
  );
}

TextTheme applyContrastToTextTheme(TextTheme base, Color baseColor, double contrast) {
  Color adjustedColor = adjustColorContrast(baseColor, contrast);

  TextStyle? applyColor(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(color: adjustedColor);
  }

  return base.copyWith(
    displayLarge: applyColor(base.displayLarge),
    displayMedium: applyColor(base.displayMedium),
    displaySmall: applyColor(base.displaySmall),
    headlineLarge: applyColor(base.headlineLarge),
    headlineMedium: applyColor(base.headlineMedium),
    headlineSmall: applyColor(base.headlineSmall),
    titleLarge: applyColor(base.titleLarge),
    titleMedium: applyColor(base.titleMedium),
    titleSmall: applyColor(base.titleSmall),
    bodyLarge: applyColor(base.bodyLarge),
    bodyMedium: applyColor(base.bodyMedium),
    bodySmall: applyColor(base.bodySmall),
    labelLarge: applyColor(base.labelLarge),
    labelMedium: applyColor(base.labelMedium),
    labelSmall: applyColor(base.labelSmall),
  );
}
