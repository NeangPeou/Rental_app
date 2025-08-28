import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/type_controller.dart';
import 'package:frontend_admin/controller/user_contoller.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/userForm/user_detail.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/userForm/user_form.dart';
import 'package:frontend_admin/screens/buildingType/buildingType.dart';
import 'package:frontend_admin/screens/systemLogs/system_logs.dart';
import 'package:frontend_admin/services/user_service.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final UserController userController = Get.put(UserController());
  final TypeController typeController = Get.put(TypeController());
  final UserService _userService = UserService();
  final TextEditingController searchController = TextEditingController();
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    userController.connectWebSocket();
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    userController.connectWebSocket();
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
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withAlpha(100),
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: InkWell(
                              onTap: () {
                                Get.to(() => const SystemLogs());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: _buildStatCard("systemLog".tr, "tabviewlog".tr, Icons.system_security_update_good),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withAlpha(100),
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Obx(() => _buildStatCard(
                              "UsersOwner".tr,
                              userController.ownerList.length.toString(),
                              Icons.person,
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor.withAlpha(100),
                                width: 1
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: InkWell(
                              onTap: () {
                                Get.to(() => const BuildingType());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: _buildStatCard("property_type".tr, "tabviewlog".tr, Icons.add_home_work_rounded),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("UsersOwnerList".tr, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Helper.sampleTextField(
                    context: context,
                    controller: searchController,
                    labelText: 'search'.tr,
                    onChanged: (value) {
                      userController.filterUsers(value); // Call filterUsers on text change
                    },
                    prefixIcon: Icon(Icons.search),
                  ),
                  SizedBox(height: 5),
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

                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: SizedBox(
                        height: Get.height * .5,
                        child: ListView.builder(
                          itemCount: userController.filteredOwnerList.length,
                          itemBuilder: (context, index) {
                            final owner = userController.filteredOwnerList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor.withAlpha(100),
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Card(
                                elevation: 1,
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  leading: CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/app_icon/sw_logo.png'), backgroundColor: Colors.transparent),
                                  title: Text(
                                    '${"name".tr}: ${owner.userName}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${"PhoneNumber".tr}: ${owner.phoneNumber}',
                                        style: Theme.of(context).textTheme.labelSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${"gender".tr}: ${owner.gender?.tr ?? "Male".tr}',
                                        style: Theme.of(context).textTheme.labelSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Show UserDetail dialog
                                    Get.dialog(
                                      UserDetail(),
                                      arguments: {
                                        'id': owner.id,
                                        'userName': owner.userName,
                                        'userID': owner.userID,
                                        'phoneNumber': owner.phoneNumber,
                                        'passport': owner.passport,
                                        'idCard': owner.idCard,
                                        'address': owner.address,
                                        'gender': owner.gender,
                                        'status': owner.status,
                                      },
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(owner.status ?? '', style: Get.textTheme.bodySmall),
                                      ),
                                      // edit button
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: const Icon(Icons.edit, size: 18),
                                        ),
                                        onTap: () {
                                          Get.to(() => UserForm(), arguments: {
                                            'title': 'UpdateOwner'.tr,
                                            'id': owner.id,
                                            'userName': owner.userName,
                                            'userID': owner.userID,
                                            'phoneNumber': owner.phoneNumber,
                                            'passport': owner.passport,
                                            'idCard': owner.idCard,
                                            'address': owner.address,
                                            'gender': owner.gender,
                                          });
                                        },
                                      ),
                                      // delete button
                                      InkWell(
                                        child: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        onTap: () {
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
                                                              Get.back();
                                                              userController.isLoading.value = true;
                                                              await _userService.deleteOwner(context, owner.id.toString());
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
                              ),
                            );
                          },
                        ),
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
