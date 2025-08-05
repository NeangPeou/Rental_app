import 'package:flutter/material.dart';

const Color firstMainThemeColor = Colors.teal;

InputDecoration textInputDecoration = InputDecoration(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
);

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.black12,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
    appBarTheme: AppBarTheme(
      backgroundColor: firstMainThemeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: firstMainThemeColor.withAlpha(100),
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      elevation: 0.0,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF282828),
    cardColor: Colors.white12,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
      backgroundColor: firstMainThemeColor.withAlpha(50),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: firstMainThemeColor.withAlpha(100),
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      elevation: 0.0
    ),
  );
}
