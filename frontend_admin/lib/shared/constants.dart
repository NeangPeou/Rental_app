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
    scaffoldBackgroundColor: Color(0xFFF0F4F8),
    cardColor: Colors.white,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
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

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[850],
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
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
