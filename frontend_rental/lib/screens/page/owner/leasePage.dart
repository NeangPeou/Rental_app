// leasePage.page
import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/page/owner/form/leaseForm.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../controller/property_controller.dart';
import '../../../services/lease_service.dart';
import '../../../shared/loading.dart';

class LeasePage extends StatefulWidget {
  const LeasePage({super.key});

  @override
  State<LeasePage> createState() => _LeasePageState();
}

class _LeasePageState extends State<LeasePage> {
  final LeaseService _leaseService = LeaseService();
  final TextEditingController searchController = TextEditingController();
  final PropertyController propertyController = Get.find<PropertyController>();
  bool isLoading = true;

  // Selection mode
  bool isSelectionMode = false;
  RxSet<String> selectedLeases = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void filter(String query) {
    if (query.isEmpty) {
      propertyController.leases.assignAll(propertyController.allLeases);
    } else {
      final queryLower = query.toLowerCase();
      propertyController.leases.assignAll(
        propertyController.allLeases.where((lease) {
          return [
            lease['username']?.toString().toLowerCase() ?? '',
            lease['unit_number']?.toString().toLowerCase() ?? '',
            lease['status']?.toString().toLowerCase() ?? '',
          ].any((field) => field.contains(queryLower));
        }).toList(),
      );
    }
  }

  Future<void> _refreshData() async {
    await _leaseService.getAllLeases();
    setState(() {
      isLoading = false;
      selectedLeases.clear();
      isSelectionMode = false;
    });
  }

  Future<void> _deleteLease(String leaseId) async {
    await _leaseService.deleteLease(leaseId);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('leases'.tr, context, null),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                const SizedBox(height: 10),

                // Selection mode actions
                if (isSelectionMode)
                  Obx(() => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Get.theme.dividerColor.withAlpha(120)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Helper.selectAllCheckbox(
                                  selectedItems: selectedLeases,
                                  items: propertyController.leases,
                                  label: 'selectall'.tr,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: selectedLeases.isEmpty
                                      ? null
                                      : () async {
                                          final confirm = await Helper.showDeleteConfirmationDialog(
                                              context, 'selected leases');
                                          if (confirm == true) {
                                            for (var leaseId in selectedLeases) {
                                              await _deleteLease(leaseId);
                                            }
                                            selectedLeases.clear();
                                            setState(() {
                                              isSelectionMode = false;
                                            });
                                            _refreshData();
                                          }
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      isSelectionMode = false;
                                      selectedLeases.clear();
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
                    if (propertyController.leases.isEmpty) {
                      return Helper.emptyData();
                    }
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        itemCount: propertyController.leases.length,
                        itemBuilder: (context, index) {
                          final lease = propertyController.leases[index];
                          final leaseId = lease['id'].toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Get.theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Get.theme.dividerColor.withAlpha(120)),
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
                                        value: selectedLeases.contains(leaseId),
                                        onChanged: (val) {
                                          if (val == true) {
                                            selectedLeases.add(leaseId);
                                          } else {
                                            selectedLeases.remove(leaseId);
                                          }
                                        },
                                      )),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      if (isSelectionMode) {
                                        if (selectedLeases.contains(leaseId)) {
                                          selectedLeases.remove(leaseId);
                                        } else {
                                          selectedLeases.add(leaseId);
                                        }
                                      } else {
                                        Get.to(() => LeaseForm(), arguments: lease);
                                      }
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        isSelectionMode = true;
                                        selectedLeases.add(leaseId);
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
                                                  lease['username'] ?? 'Unknown Renter',
                                                  style: Get.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.apartment_rounded,
                                                        size: 14, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        'Unit: ${lease['unit_number'] ?? ''}',
                                                        style: Get.textTheme.bodySmall,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text('Status: ${lease['status']}',
                                                    style: Get.textTheme.bodySmall,
                                                    overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade100,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.calendar_today,
                                                              size: 12, color: Colors.blue),
                                                          const SizedBox(width: 4),
                                                          Flexible(
                                                            child: ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth: Get.width * 0.22,
                                                              ),
                                                              child: Text(
                                                                lease['start_date'].toString(),
                                                                style: Get.textTheme.bodySmall
                                                                    ?.copyWith(color: Colors.blue[800]),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(17), bottom: Radius.circular(17)),
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
              Get.to(() => LeaseForm(), arguments: {});
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(
              Icons.edit_document,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
