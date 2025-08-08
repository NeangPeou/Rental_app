import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/appearance.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/my_account.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 10),
          _buildSectionTitle("Account Settings"),
          _buildSettingsTile(Icons.person, "My Account", onTap: () {
            Get.to(() => const MyAccount(), arguments: "My Account");
          }),
          _buildSettingsTile(Icons.security, "Privacy & Safety", onTap: () {}),
          _buildSettingsTile(Icons.notifications, "Notifications", onTap: () {}),

          _buildSectionTitle("App Settings"),
          _buildSettingsTile(Icons.palette, "Appearance", onTap: () {
            Get.to(() => const Appearance(), arguments: "Appearance");
          }),
          Obx(() {
            return _buildSwitchTile(
              Icons.dark_mode,
              "Dark Mode",
              settingController.isDarkMode.value, (value) => settingController.toggleTheme(value),
            );
          }),
          _buildSettingsTile(Icons.language, "Language", onTap: () {}),

          _buildSectionTitle("Support"),
          _buildSettingsTile(Icons.help_outline, "Help", onTap: () {}),
          _buildSettingsTile(Icons.feedback, "Feedback", onTap: () {}),

          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                "Log Out",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
              ),
              onPressed: () {
                Get.defaultDialog(
                  contentPadding: EdgeInsets.all(20),
                  titlePadding: EdgeInsets.only(top: 20),
                  title: "Log Out",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  content: Text("Are you sure you want to log out?"),
                  cancel: ElevatedButton(
                    onPressed: () async {
                      await _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Center(
                      child: Text(
                        "Log Out",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  confirm: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withAlpha(5),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Text(title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: firstMainThemeColor,
    );
  }


}
