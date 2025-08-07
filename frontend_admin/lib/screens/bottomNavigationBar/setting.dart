import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/appearance.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/my_account.dart';
import 'package:frontend_admin/services/auth.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final AuthService _authService = AuthService();
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
              icon: Icon(Icons.logout,color: Colors.white,),
              label: Text("Log Out", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),),
              onPressed: () {
                Get.defaultDialog(
                  contentPadding: EdgeInsets.all(20),
                  titlePadding: EdgeInsets.only(top: 20),
                  title: "Log Out",
                  titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  content: Text("Are you sure you to want to log out?"),
                  cancel: ElevatedButton(
                    onPressed: () {
                      _authService.signOut();
                      Get.offAllNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Center(
                      child: Text("Log Out", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white))
                    )
                  ),
                  confirm: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withAlpha(5),
                    ),
                    child: Center(
                      child: Text("Cancel",style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white))
                    )
                  )
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
