import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/appearance.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/my_account.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

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
          _buildSectionTitle("Account Settings"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.person, "My Account", onTap: () {
                  Get.to(() => const MyAccount(), arguments: "My Account");
                }),
                Divider(height: 0),
                _buildSettingsTile(Icons.security, "Privacy & Safety", onTap: () {}),
                Divider(height: 0),
                _buildSettingsTile(Icons.notifications, "Notifications", onTap: () {}),
              ],
            )
          ),

          _buildSectionTitle("App Settings"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.palette, "Appearance", onTap: () {
                  Get.to(() => const Appearance(), arguments: "Appearance");
                }),
                Divider(height: 0),
                Obx(() {
                  return _buildSwitchTile(
                    Icons.dark_mode,
                    "Dark Mode",
                    settingController.isDarkMode.value ?? false,
                    (value) => settingController.toggleTheme(value),
                  );
                }),
                Divider(height: 0),
                _buildSettingsTile(Icons.language, "Language", onTap: () {}),
              ],
            ),
          ),

          _buildSectionTitle("Support"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.help_outline, "Help", onTap: () {}),
                Divider(height: 0),
                _buildSettingsTile(Icons.feedback, "Feedback", onTap: () {}),
              ],
            ),
          ),

          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x1AFF0000),
                radius: 18,
                child: Icon(Icons.logout_sharp, color: Colors.red, size: 20),
              ),
              title: Text("Log Out", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red)),
              onTap: (){
                Get.defaultDialog(
                  radius: 10,
                  contentPadding: EdgeInsets.all(20),
                  titlePadding: EdgeInsets.only(top: 20),
                  title: "Log Out",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  content: Text("Are you sure you want to log out?", style: Get.textTheme.bodyMedium),
                  cancel: ElevatedButton(
                    onPressed: () async {
                      await _logout(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: Center(
                      child: Text("Log Out", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
                    ),
                  ),
                  confirm: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).focusColor),
                    child: Center(
                      child: Text("Cancel", style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ),
                );
              },
            ),
          ),

          _buildSectionTitle("Developer Settings"),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.cached),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  title: Text("Cache Action", style: Theme.of(context).textTheme.titleMedium),
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
                                child: Text("Clear Caches", style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 40),

                              // Message
                              Center(
                                child: Text("Are you sure you want to clear caches?", style: Get.textTheme.bodyMedium),
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
                                      child: Text("Cancel", style: Get.textTheme.labelMedium),
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
                                                    Text('Caches Cleared!', style: TextStyle(color: Theme.of(context).dividerColor)),
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
                                      child: Text("Clear", style: Get.textTheme.labelMedium?.copyWith(color: Colors.white)),
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
                                Text('Copied to clipboard.'),
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
                  title: Text("Device Info", style: Theme.of(context).textTheme.titleMedium),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout. Please try again.')),
      );
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
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      value: value,
      onChanged: onChanged,
      activeColor: settingController.selectedColor.value,
    );
  }

}
