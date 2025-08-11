import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/screens/authenticate/login.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/screens/wrapper.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:frontend_admin/storage/storage_keys.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  Get.put(SettingController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final SettingController _settingController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      themeMode: _settingController.box.hasData(StorageKeys.isDarkMode) ? (_settingController.isDarkMode.value == true ? ThemeMode.dark : ThemeMode.light) : ThemeMode.system,
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
