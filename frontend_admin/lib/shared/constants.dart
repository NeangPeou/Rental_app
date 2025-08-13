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
  final contrast = settingController.contrast.value;
  final saturation = settingController.saturation.value;
  final baseTextTheme = defaultTextTheme();
  final contrastedTextTheme = applyContrastToTextTheme(baseTextTheme, Colors.black, contrast, saturation);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: adjustColor(Color(0xFFF0F4F8), contrast, saturation),
    cardColor: adjustColor(settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value.withAlpha(70) : Colors.white, contrast, saturation),
    textTheme: contrastedTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: adjustColor(settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value : Colors.teal, contrast, saturation),
        foregroundColor: adjustColor(Colors.black, contrast, saturation),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, inherit: true),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: adjustColor(firstMainThemeColor, contrast, saturation),
      foregroundColor: adjustColor(Colors.black, contrast, saturation),
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: adjustColor(firstMainThemeColor, contrast, saturation),
      selectedItemColor: adjustColor(Colors.amber, contrast, saturation),
      unselectedItemColor: adjustColor(Colors.white, contrast, saturation),
      elevation: 0.0,
    ),
  );
}

ThemeData darkTheme([Color? primaryColor]) {
  final contrast = settingController.contrast.value;
  final saturation = settingController.saturation.value;
  final baseTextTheme = defaultTextTheme();
  final contrastedTextTheme = applyContrastToTextTheme(baseTextTheme, Colors.white, contrast, saturation);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: adjustColor(Color(0xFF2C2F33), contrast, saturation),
    cardColor: adjustColor(settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value.withAlpha(70) : Colors.grey[850]!, contrast, saturation),
    textTheme: contrastedTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: adjustColor(settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value : Colors.teal, contrast, saturation),
        foregroundColor: adjustColor(Colors.white, contrast, saturation),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, inherit: true),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: adjustColor(settingController.selectedColor.value, contrast, saturation),
      foregroundColor: adjustColor(Colors.white, contrast, saturation),
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: adjustColor(settingController.selectedColor.value, contrast, saturation),
      selectedItemColor: adjustColor(Colors.amber, contrast, saturation),
      unselectedItemColor: adjustColor(Colors.white, contrast, saturation),
      elevation: 0.0,
    ),
  );
}

Color adjustColor(Color color, double contrast, double saturation) {
  contrast = contrast.clamp(0.5, 2.0);

  int adjustComponent(int value) {
    final factor = (value - 128) * contrast + 128;
    return factor.clamp(0, 255).toInt();
  }

  final contrastedColor = Color.fromARGB(
    color.alpha,
    adjustComponent(color.red),
    adjustComponent(color.green),
    adjustComponent(color.blue),
  );

  final hsl = HSLColor.fromColor(contrastedColor);
  final saturated = hsl.withSaturation((hsl.saturation * saturation).clamp(0.0, 1.0));
  return saturated.toColor();
}

TextTheme applyContrastToTextTheme(TextTheme base, Color baseColor, double contrast, double saturation) {
  final adjustedColor = adjustColor(baseColor, contrast, saturation);
  final fontSizeScale = settingController.fontSize.value;

  TextStyle? applyColor(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(
      color: adjustedColor,
      fontSize: style.fontSize != null ? style.fontSize! * fontSizeScale : null,
    );
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

TextTheme defaultTextTheme() {
  return const TextTheme(
    displayLarge: TextStyle(fontSize: 57, height: 64 / 57, fontWeight: FontWeight.normal, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, height: 52 / 45, fontWeight: FontWeight.normal, letterSpacing: 0.0),
    displaySmall: TextStyle(fontSize: 36, height: 44 / 36, fontWeight: FontWeight.normal, letterSpacing: 0.0),

    headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.normal, letterSpacing: 0.0),
    headlineMedium: TextStyle(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.normal, letterSpacing: 0.0),
    headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.normal, letterSpacing: 0.0),

    titleLarge: TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.normal, letterSpacing: 0.0),
    titleMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),

    bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),

    labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}


