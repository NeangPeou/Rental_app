import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/renterForm/renter_form.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../controller/property_controller.dart';
import '../../../services/user_service.dart';
import '../../../shared/loading.dart';

class RenterPage extends StatefulWidget {
  const RenterPage({super.key});

  @override
  State<RenterPage> createState() => _RenterPageState();
}

class _RenterPageState extends State<RenterPage> {
  final UserService _userService = UserService();
  final TextEditingController searchController = TextEditingController();
  final PropertyController propertyController = Get.find<PropertyController>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllRenters();
  }

  Future<void> getAllRenters() async {
    final renters = await _userService.fetchRenters(context);
    propertyController.setRenters(renters.map((renter) => renter.toJson()).toList());
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await getAllRenters();
  }

  void filter(String query) {
    if (query.isEmpty) {
      propertyController.renters.assignAll(propertyController.allRenters);
    } else {
      final queryLower = query.toLowerCase();
      propertyController.renters.assignAll(
        propertyController.allRenters.where((renter) {
          return [
            renter['userName']?.toString().toLowerCase() ?? '',
            renter['phoneNumber']?.toString().toLowerCase() ?? '',
            renter['address']?.toString().toLowerCase() ?? '',
          ].any((field) => field.contains(queryLower));
        }).toList(),
      );
    }
  }

  Future<void> _deleteRenter(String renterId) async {
    await _userService.deleteRenter(context, renterId);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: Helper.sampleAppBar('tenants'.tr, context, null),
            body: SafeArea(
              bottom: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
                ),
                child: Column(
                  children: [
                    Helper.smallSearchField(
                      context: context,
                      controller: searchController,
                      onChanged: (value) => filter(value),
                      hintText: 'search'.tr,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Obx(() {
                        if (propertyController.renters.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/empty.gif',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                Text('No Renters Found', style: Get.textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text('Start by adding a new renter.', style: Get.textTheme.bodySmall),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _refreshData,
                          child: ListView.builder(
                            itemCount: propertyController.renters.length,
                            itemBuilder: (context, index) {
                              final renter = propertyController.renters[index];

                              return Dismissible(
                                key: Key(renter['id']?.toString() ?? UniqueKey().toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  final renterId = renter['id']?.toString();
                                  if (renterId == null) return false;
                                  return await Helper.showDeleteConfirmationDialog(context, renterId);
                                },
                                onDismissed: (direction) {
                                  final renterId = renter['id']?.toString();
                                  if (renterId != null) {
                                    _deleteRenter(renterId);
                                  }
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.delete, color: Colors.white, size: 30),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Get.theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      // Navigate to RenterForm and await result
                                      await Get.to(() => RenterForm(), arguments: renter);
                                      await _refreshData(); // Refresh after returning
                                    },
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.horizontal(
                                              left: Radius.circular(12), right: Radius.circular(12)),
                                          child: Image.asset(
                                            'assets/app_icon/sw_logo.png',
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(renter['userName'] ?? 'Unknown Renter',
                                                    style: Get.textTheme.titleSmall
                                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        renter['phoneNumber'] ?? '',
                                                        style: Get.textTheme.bodySmall,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        renter['address'] ?? '',
                                                        style: Get.textTheme.bodySmall,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[200], // light green background
                                                        borderRadius: BorderRadius.circular(12), // pill shape
                                                      ),
                                                      child: Text(
                                                        renter['gender'] ?? '',
                                                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.green[800]),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red, size: 24),
                                          onPressed: () async {
                                            final renterId = renter['id']?.toString();
                                            if (renterId == null) return;
                                            final confirm =
                                                await Helper.showDeleteConfirmationDialog(context, renterId);
                                            if (confirm == true) {
                                              await _deleteRenter(renterId);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17), bottom: Radius.circular(17)),
                border: Border.all(color: Theme.of(context).primaryColorDark.withAlpha(100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Get.to(() => RenterForm(), arguments: '');
                    _refreshData();
                  },
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
  }
}