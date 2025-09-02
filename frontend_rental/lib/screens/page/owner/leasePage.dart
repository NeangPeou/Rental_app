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

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void filter(String query) {
    final PropertyController controller = Get.find<PropertyController>();

    if (query.isEmpty) {
      controller.leases.assignAll(controller.allLeases);
    } else {
      controller.leases.assignAll(
        controller.allLeases.where((lease) {
          final queryLower = query.toLowerCase();
          return (
              (lease['username'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (lease['unit_number'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (lease['status'] ?? '').toString().toLowerCase().contains(queryLower)
          );
        }).toList(),
      );
    }
  }

  Future<void> _refreshData() async {
    await _leaseService.getAllLeases();
    setState(() {
      isLoading = false;
    });
  }

   // Function to handle lease deletion
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
                  if (propertyController.leases.isEmpty) {
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
                          Text('No Leases Found', style: Get.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Start by adding a new lease.', style: Get.textTheme.bodySmall),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _refreshData(),
                    child: ListView.builder(
                      itemCount: propertyController.leases.length,
                      itemBuilder: (context, index) {
                        final lease = propertyController.leases[index];

                        return Dismissible(
                          key: Key(lease['id'].toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await Helper.showDeleteConfirmationDialog(context, lease['id'].toString());
                          },
                          onDismissed: (direction) async {
                            await _deleteLease(lease['id'].toString());
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
                              onTap: () {
                                Get.to(() => LeaseForm(), arguments: lease);
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
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
                                          Text(lease['username'] ?? 'Unknown Renter', style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.apartment_rounded, size: 14, color: Colors.grey),
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
                                          Text('Status: ${lease['status']}', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 12, color: Colors.blue),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          maxWidth: Get.width * 0.22,
                                                        ),
                                                        child: Text(
                                                          lease['start_date'].toString(),
                                                          style: Get.textTheme.bodySmall?.copyWith(color: Colors.blue[800]),
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
                                  // Delete Icon Button
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red, size: 24),
                                    onPressed: () async {
                                      final confirm = await Helper.showDeleteConfirmationDialog(context, lease['id'].toString());
                                      if (confirm == true) {
                                        await _deleteLease(lease['id'].toString());
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