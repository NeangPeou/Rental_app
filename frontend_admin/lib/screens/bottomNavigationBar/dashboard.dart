import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/userForm/user_form.dart';
import 'package:frontend_admin/services/user_service.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final UserController userController = Get.put(UserController());
  final UserService _userService = UserService();
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    userController.connectWebSocket();
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard("Requests", "02", Icons.message),
                      const SizedBox(width: 12),
                      Obx(() => _buildStatCard("UsersOwner".tr, userController.ownerList.length.toString(), Icons.person)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("UsersOwnerList".tr, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Obx(() {
                    if (userController.isLoading.value) {
                      return SizedBox(
                        height: Get.height * .5,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (userController.ownerList.isEmpty) {
                      return SizedBox(height: Get.height * .5, child: Center(child: Text("NoUser".tr)));
                    }

                    return SizedBox(
                      height: Get.height * .5,
                      child: ListView.builder(
                        itemCount: userController.ownerList.length,
                        itemBuilder: (context, index) {
                          final owner = userController.ownerList[index];
                          return Card(
                            elevation: 1,
                            color: Colors.teal,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              // leading: CircleAvatar(radius: 20, backgroundImage: AssetImage(owner.image ?? 'assets/images/user.png')),
                              title: Text(owner.userName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              subtitle: Text(owner.phoneNumber, style: Theme.of(context).textTheme.bodySmall),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(owner.status ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(width: 8),
                                  // edit button
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () {
                                      Get.to(() => UserForm(), arguments: {
                                        'title': 'UpdateOwner'.tr,
                                        'id': owner.id,
                                        'userName': owner.userName,
                                        'userID': owner.userID,
                                        'phoneNumber': owner.phoneNumber,
                                        'passport': owner.passport,
                                        'idCard': owner.idCard,
                                        'address': owner.address,
                                      },
                                      );
                                    },
                                  ),
                                  // delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () {
                                      Get.dialog(
                                        Dialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                                  child: const Icon(Icons.warning_rounded, color: Colors.red, size: 40),
                                                ),
                                                const SizedBox(height: 16),
                                                // Title
                                                Text('ConfirmDelete'.tr, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                // Content
                                                Text('AreYouSureDelete'.tr.replaceFirst('{userName}', owner.userName), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                                                const SizedBox(height: 20),
                                                // Buttons
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    // Cancel Button
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        ),
                                                        onPressed: () => Get.back(),
                                                        child: Text('cancel'.tr),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    // Delete Button
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        ),
                                                        onPressed: () async{
                                                          await _userService.deleteOwner(context, owner.id.toString());
                                                          Get.back();
                                                        },
                                                        child: Text('delete'.tr, style: const TextStyle(color: Colors.white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
