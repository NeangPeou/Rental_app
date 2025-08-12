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
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF0F4F8),
    cardColor: settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value.withAlpha(70) : Colors.white,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value : Colors.teal,
        foregroundColor: Colors.black,
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
      backgroundColor: firstMainThemeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: firstMainThemeColor,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      elevation: 0.0,
    ),
  );
}

ThemeData darkTheme([Color? primaryColor]) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value.withAlpha(70) : Colors.grey[850],
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: settingController.box.hasData(StorageKeys.selectedColor) ? settingController.selectedColor.value : Colors.teal,
        foregroundColor: Colors.black,
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
      backgroundColor: firstMainThemeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: firstMainThemeColor,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      elevation: 0.0
    ),
  );
}
