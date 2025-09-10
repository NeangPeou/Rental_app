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

  // Selection mode
  bool isSelectionMode = false;
  RxSet<String> selectedRenters = <String>{}.obs;

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
      selectedRenters.clear();
      isSelectionMode = false;
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Get.theme.dividerColor.withAlpha(120),
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: [
                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Helper.smallSearchField(
                          context: context,
                          controller: searchController,
                          onChanged: (value) => filter(value),
                          hintText: 'search'.tr,
                        ),
                      ),
                      // Selection mode actions
                      if (isSelectionMode)
                        Obx(() => Container(
                          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Get.theme.dividerColor.withAlpha(120)),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Helper.selectAllCheckbox(
                                    selectedItems: selectedRenters,
                                    items: propertyController.renters,
                                    label: 'selectall'.tr,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: selectedRenters.isEmpty
                                      ? null
                                      : () async {
                                        final confirm = await Helper.showDeleteConfirmationDialog(
                                          context, 'selected renters');
                                        if (confirm == true) {
                                        for (var renterId in selectedRenters) {
                                          _deleteRenter(renterId);
                                        }
                                        selectedRenters.clear();
                                        setState(() {
                                          isSelectionMode = false;
                                        });
                                        }
                                      },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        isSelectionMode = false;
                                        selectedRenters.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      Expanded(
                        child: Obx(() {
                          if (propertyController.renters.isEmpty) {
                            return Helper.emptyData();
                          }
                          return RefreshIndicator(
                            onRefresh: _refreshData,
                            child: ListView.builder(
                              itemCount: propertyController.renters.length,
                              itemBuilder: (context, index) {
                                final renter = propertyController.renters[index];
                                final renterId = renter['id']?.toString() ?? '';
                  
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Get.theme.cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          if (isSelectionMode)
                                            Obx(() => Checkbox(
                                                  value: selectedRenters.contains(renterId),
                                                  onChanged: (val) {
                                                    if (val == true) {
                                                      selectedRenters.add(renterId);
                                                    } else {
                                                      selectedRenters.remove(renterId);
                                                    }
                                                  },
                                                )),
                                          Expanded(
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12),
                                              onTap: () async {
                                                if (isSelectionMode) {
                                                  if (selectedRenters.contains(renterId)) {
                                                    selectedRenters.remove(renterId);
                                                  } else {
                                                    selectedRenters.add(renterId);
                                                  }
                                                } else {
                                                  await Get.to(() => RenterForm(), arguments: renter);
                                                  await _refreshData();
                                                }
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  isSelectionMode = true;
                                                  selectedRenters.add(renterId);
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                      right: Radius.circular(12),
                                                    ),
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
                                                          Text(
                                                            renter['userName'] ?? 'Unknown Renter',
                                                            style: Get.textTheme.titleSmall
                                                                ?.copyWith(fontWeight: FontWeight.bold),
                                                          ),
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
                                                                  color: Colors.green[200],
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                child: Text(
                                                                  renter['gender'] ?? '',
                                                                  style: Get.textTheme.bodySmall
                                                                      ?.copyWith(color: Colors.green[800]),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Add icon to top-right
                                    Positioned(
                                      right: 0,
                                      top: -10,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          Get.dialog(
                                            Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Card(
                                                color: Get.theme.scaffoldBackgroundColor,
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(
                                                    color: Get.theme.dividerColor.withAlpha(120),
                                                    width: 1.50
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            'renterDetail'.tr,
                                                            style: Get.theme.textTheme.titleLarge?.copyWith(
                                                              fontWeight: FontWeight.w400
                                                            )
                                                          ),
                                                          Spacer(),
                                                          IconButton(
                                                            icon: const Icon(Icons.close),
                                                            onPressed: () {
                                                              Get.back(); // Closes the dialog
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      SizedBox(height: 5,),
                                                        Center(
                                                        child: CircleAvatar(
                                                          radius: 50,
                                                          backgroundImage: const AssetImage('assets/app_icon/sw_logo.png'),
                                                          child: Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: Colors.teal,
                                                              width: 3,
                                                            ),
                                                          ),
                                                          ),
                                                        ),
                                                        ),
                                                      const SizedBox(height: 10),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['userName'] ?? 'N/A'),
                                                        labelText: 'Username'.tr,
                                                        prefixIcon: const Icon(Icons.person),
                                                        enabled: false,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['phoneNumber'] ?? 'N/A'),
                                                        labelText: 'PhoneNumber'.tr,
                                                        prefixIcon: const Icon(Icons.phone),
                                                        enabled: false,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['passport'] ?? 'N/A'),
                                                        labelText: 'Passport'.tr,
                                                        prefixIcon: const Icon(Icons.phone),
                                                        enabled: false,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['idCard'] ?? 'N/A'),
                                                        labelText: 'IDCard'.tr,
                                                        prefixIcon: const Icon(Icons.phone),
                                                        enabled: false,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['address'] ?? 'N/A'),
                                                        labelText: 'Address'.tr,
                                                        prefixIcon: const Icon(Icons.location_on),
                                                        enabled: false,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Helper.sampleTextField(
                                                        context: context,
                                                        controller: TextEditingController(text: renter['gender'] ?? 'N/A'),
                                                        labelText: 'gender'.tr,
                                                        prefixIcon: const Icon(Icons.person),
                                                        enabled: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  ],
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
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17), bottom: Radius.circular(17)),
                border: Border.all(color: Theme.of(context).primaryColorDark.withAlpha(100)),
                boxShadow: const [
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
