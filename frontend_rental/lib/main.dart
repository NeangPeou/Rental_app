import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/controller/setting_controller.dart';
import 'package:frontend_rental/screens/authenticate/login.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_rental/screens/page/owner/propertyPage.dart';
import 'package:frontend_rental/screens/page/rental/rentalPage.dart';
import 'package:frontend_rental/screens/splashScreen.dart';
import 'package:frontend_rental/screens/wrapper.dart';
import 'package:frontend_rental/services/inactivityService.dart';
import 'package:frontend_rental/shared/constants.dart';
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
          initialRoute: '/splash',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: lightTheme(selectedColor),
          darkTheme: darkTheme(selectedColor),
          getPages: [
            GetPage(name: '/splash', page: () => const SplashScreen()),
            GetPage(name: '/', page: () => const Wrapper()),
            GetPage(name: '/login', page: () => const Login()),
            GetPage(name: '/property_page', page: () => const PropertyPage()),
            GetPage(name: '/rental_page', page: () => const RentalPage()),
          ],
        ),
      );
    });
  }
}
