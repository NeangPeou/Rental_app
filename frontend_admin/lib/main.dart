import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/screens/authenticate/login.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/screens/wrapper.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      themeMode: ThemeMode.system,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      getPages: [
        GetPage(name: '/', page: () => const Wrapper()),
        GetPage(name: '/login', page: () => const Login()),
        GetPage(name: '/home', page: () => const Home()),
      ],
    );
  }
}
