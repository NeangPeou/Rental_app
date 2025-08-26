import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/screens/authenticate/login.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_admin/screens/home/home.dart';
import 'package:frontend_admin/screens/wrapper.dart';
import 'package:frontend_admin/services/inactivityService.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/user_contoller.dart';
import 'translate//AppTranslations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  Get.put(SettingController());
  Get.put(UserController());
  InactivityService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final SettingController _settingController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = _settingController.isDarkMode.value ?? false;
      final selectedColor = _settingController.selectedColor.value;
      final selectedLang = _settingController.selectedLanguage.value;
      final selectedLocale = Setting.languages.firstWhere((lang) => lang['name'] == selectedLang, orElse: () => {'locale': Locale('en', 'US')})['locale'] as Locale;

      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => InactivityService().userInteractionDetected(),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: selectedLocale,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: '/',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: lightTheme(selectedColor),
          darkTheme: darkTheme(selectedColor),
          getPages: [
            GetPage(name: '/', page: () => const Wrapper()),
            GetPage(name: '/login', page: () => const Login()),
            GetPage(name: '/home', page: () => const Home()),
          ],
        ),
      );
    });
  }
}
