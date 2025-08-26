import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/controller/setting_controller.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/setting_pages/appearance.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/setting_pages/my_account.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag/flag.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});
  static final languages = [
    {'nameKey': 'khmer', 'name': 'Khmer', 'code': FlagsCode.KH, 'locale': Locale('km', 'KH')},
    {'nameKey': 'english', 'name': 'English', 'code': FlagsCode.US, 'locale': Locale('en', 'US')},
    {'nameKey': 'spanish', 'name': 'Spanish', 'code': FlagsCode.ES, 'locale': Locale('es', 'ES')},
    {'nameKey': 'french', 'name': 'French', 'code': FlagsCode.FR, 'locale': Locale('fr', 'FR')},
    {'nameKey': 'german', 'name': 'German', 'code': FlagsCode.DE, 'locale': Locale('de', 'DE')},
    {'nameKey': 'japanese', 'name': 'Japanese', 'code': FlagsCode.JP, 'locale': Locale('ja', 'JP')},
    {'nameKey': 'chinese', 'name': 'Chinese', 'code': FlagsCode.CN, 'locale': Locale('zh', 'CN')},
    {'nameKey': 'russian', 'name': 'Russian', 'code': FlagsCode.RU, 'locale': Locale('ru', 'RU')},
    {'nameKey': 'korean', 'name': 'Korean', 'code': FlagsCode.KR, 'locale': Locale('ko', 'KR')},
  ];

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  SettingController settingController = Get.put(SettingController());
  final box = GetStorage();
  Map<String, dynamic> deviceInfo = {};

  Future<void> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceInfo = {
        'Model': androidInfo.model,
        'Version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceInfo = {
        'DeviceName': iosInfo.name,
        'Model': iosInfo.model,
        'Version': iosInfo.systemVersion,
      };
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfoPlugin.windowsInfo;
      deviceInfo = {
        'Model': windowsInfo.computerName,
        'Version': windowsInfo.csdVersion,
      };
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfoPlugin.macOsInfo;
      deviceInfo = {
        'Model': macInfo.model,
        'Version': macInfo.osRelease,
      };
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfoPlugin.linuxInfo;
      deviceInfo = {
        'Name': linuxInfo.name,
        'Version': linuxInfo.version,
      };
    } else {
      deviceInfo = {
        'Platform': 'Unknown',
        'Error': 'Unsupported platform',
      };
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 10),
          _buildSectionTitle('account_settings'),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.person, "my_account", onTap: () {
                  Get.to(() => const MyAccount(), arguments: {'title': 'my_account'.tr});
                }),
                Divider(height: 0),
                _buildSettingsTile(Icons.security, "privacy_safety", onTap: () {}),
                Divider(height: 0),
                _buildSettingsTile(Icons.notifications, "notifications", onTap: () {
                  showNotificationBottomSheet();
                }),
              ],
            )
          ),

          _buildSectionTitle("app_settings"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.palette, "appearance", onTap: () {
                  Get.to(() => const Appearance(), arguments: "appearance".tr);
                }),
                Divider(height: 0),
                Obx(() {
                  return _buildCupertinoSwitchTile(
                    Icons.dark_mode,
                    "dark_mode",
                    settingController.isDarkMode.value ?? false,
                    (value) => settingController.toggleTheme(value),
                  );
                }),
                Divider(height: 0),
                _buildSettingsTile(Icons.language, "language", onTap: () {
                  showLanguageBottomSheet();
                }),
              ],
            ),
          ),

          _buildSectionTitle("support"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.help_outline, "help", onTap: () {}),
                Divider(height: 0),
                _buildSettingsTile(Icons.feedback, "feedback", onTap: () {}),
              ],
            ),
          ),

          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x1AFF0000),
                radius: 18,
                child: Icon(Icons.logout_sharp, color: Colors.red, size: 20),
              ),
              title: Text('logout'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
              onTap: (){
                Get.defaultDialog(
                  radius: 10,
                  contentPadding: EdgeInsets.all(20),
                  titlePadding: EdgeInsets.only(top: 20),
                  title: "logout".tr,
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  content: Text("logout_confirmation".tr, style: Get.textTheme.bodyMedium),
                  cancel: ElevatedButton(
                    onPressed: () async {
                      await _logout(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: Center(
                      child: Text("logout".tr, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
                    ),
                  ),
                  confirm: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).focusColor),
                    child: Center(
                      child: Text("cancel".tr, style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ),
                );
              },
            ),
          ),

          _buildSectionTitle("developer_settings"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.cached),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  title: Text("cache_action".tr, style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () {
                    Get.bottomSheet(
                      SafeArea(
                        bottom: true,
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 15),
                          decoration: BoxDecoration(
                            color: Get.theme.scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
                          ),
                          child: Wrap(
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),

                              // Title
                              Center(
                                child: Text("clear_caches".tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 40),

                              // Message
                              Center(
                                child: Text("clear_caches_confirmation".tr, style: Get.textTheme.bodyMedium),
                              ),
                              const SizedBox(height: 40),

                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("cancel".tr, style: Get.textTheme.labelMedium),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.snackbar(
                                            '', '',
                                            titleText: Center(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.layers_clear_sharp, color: Theme.of(context).dividerColor, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('caches_cleared'.tr, style: TextStyle(color: Theme.of(context).dividerColor)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            maxWidth: Get.width * .9,
                                            backgroundColor: Colors.transparent,
                                            snackPosition: SnackPosition.TOP,
                                            snackStyle: SnackStyle.FLOATING,
                                            padding: EdgeInsets.zero,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: false,
                                            animationDuration: const Duration(milliseconds: 200),
                                            overlayBlur: 0.0,
                                            barBlur: 0.0,
                                            boxShadows: [],
                                            overlayColor: Colors.transparent
                                        );
                                        settingController.clearStorage();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: Text("clear".tr, style: Get.textTheme.labelMedium?.copyWith(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
                Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.devices_other_sharp),
                  trailing: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: "${deviceInfo['Model'] ?? ''}(${deviceInfo['Version'] ?? ''})"));
                      Get.snackbar(
                        '', '',
                        titleText: Center(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy, color: Theme.of(context).dividerColor, size: 18),
                                SizedBox(width: 8),
                                Text('copied_clipboard'.tr),
                              ],
                            ),
                          ),
                        ),
                        maxWidth: Get.width * .9,
                        backgroundColor: Colors.transparent,
                        snackPosition: SnackPosition.TOP,
                        snackStyle: SnackStyle.FLOATING,
                        padding: EdgeInsets.zero,
                        duration: const Duration(milliseconds: 1500),
                        isDismissible: false,
                        animationDuration: const Duration(milliseconds: 200),
                        overlayBlur: 0.0,
                        barBlur: 0.0,
                        boxShadows: [],
                        overlayColor: Colors.transparent
                      );
                    },
                    child: Text("${deviceInfo['Model'] ?? ''}(${deviceInfo['Version'] ?? ''})"),
                  ),
                  title: Text("device_info_label".tr, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // logout function
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        return;
      }
    } catch (e) {
      return;
    }
    // Clear token and navigate to login
    await prefs.setString('x-auth-token', '');
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, bottom: 5),
      child: Text(
          title.tr,
          style: Theme.of(context).textTheme.bodyMedium
      ),
    );
  }

  Widget _buildSettingsTile(IconData? icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title.tr, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildCupertinoSwitchTile(IconData? icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) Icon(icon, size: 24),
          if (icon != null) SizedBox(width: 12),
          Expanded(
            child: Text(title.tr, style: Get.textTheme.bodyMedium),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void showLanguageBottomSheet() {
    Get.bottomSheet(
      SafeArea(
        bottom: true,
        child: Obx(() => Container(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 15),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Text("select_language".tr, style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Get.theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(Setting.languages.length, (index) {
                      final lang = Setting.languages[index];
                      final isLast = index == Setting.languages.length - 1;

                      return Column(
                        children: [
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Flag.fromCode(
                                lang['code'] as FlagsCode,
                                width: 30,
                                height: 20,
                                fit: BoxFit.fill,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lang['name'] as String),
                                Text((lang['nameKey'] as String).tr, style: Get.textTheme.labelMedium?.copyWith(color: Colors.grey)),
                              ],
                            ),
                            trailing: Radio<String>(
                              value: lang['name'] as String,
                              groupValue: settingController.selectedLanguage.value,
                              onChanged: (value) {
                                if (value != null) {
                                  settingController.setLanguage(value);
                                  Get.updateLocale(lang['locale'] as Locale);
                                }
                              },
                            ),
                            onTap: () {
                              settingController.setLanguage(lang['name'] as String);
                              Get.updateLocale(lang['locale'] as Locale);
                            },
                          ),
                          if (!isLast) const Divider(height: 1),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
      isScrollControlled: true,
    );
  }

  void showNotificationBottomSheet() {
    Get.bottomSheet(
      SafeArea(
        bottom: false,
        child: Container(
          height: Get.height * .5,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 15),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Text("In-app notifications", style: Theme.of(context).textTheme.bodyMedium),
              Obx(() => Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: _buildCupertinoSwitchTile(
                  null,
                  "Get notifications within App.",
                  settingController.inAppNotifications.value,
                  (value) {
                    settingController.setNotificationInApp(value);
                  },
                ),
              )),
              SizedBox(height: 20),
              Text("System notifications", style: Theme.of(context).textTheme.bodyMedium),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: _buildSettingsTile(null, "Get notifications outside of App.", onTap: (){
                  AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
