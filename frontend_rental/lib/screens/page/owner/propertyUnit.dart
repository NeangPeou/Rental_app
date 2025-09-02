import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/page/owner/form/propertyUnitForm.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import '../../../controller/property_controller.dart';
import '../../../services/property_service.dart';
import '../../../shared/loading.dart';

class PropertyUnit extends StatefulWidget {
  const PropertyUnit({super.key});

  @override
  State<PropertyUnit> createState() => _PropertyUnitState();
}

class _PropertyUnitState extends State<PropertyUnit> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController searchController = TextEditingController();
  final PropertyController propertyController = Get.put(PropertyController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void filter(String query) {
    final PropertyController controller = Get.find<PropertyController>();

    if (query.isEmpty) {
      controller.units.assignAll(controller.allUnits);
    } else {
      controller.units.assignAll(
        controller.allUnits.where((property) {
          final queryLower = query.toLowerCase();

          return (
              (property['unit_number'] ?? '').toString().toLowerCase().contains(queryLower)) ||
              (property['size'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['rent'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['is_available'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['property_name'] ?? '').toString().toLowerCase().contains(queryLower);
        }).toList(),
      );
    }
  }

  Future<void> _refreshData() async {
    await _propertyService.getAllUnits();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('Property Unit', context, null),
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
              Helper.sampleTextField(
                context: context,
                controller: searchController,
                labelText: 'search'.tr,
                onChanged: (value) {
                  filter(value);
                },
                prefixIcon: Icon(Icons.search),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (propertyController.units.isEmpty) {
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
                          Text('No Properties Found', style: Get.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Start by adding a new property.', style: Get.textTheme.bodySmall),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _refreshData(),
                    child: ListView.builder(
                      itemCount: propertyController.units.length,
                      itemBuilder: (context, index) {
                        final property = propertyController.units[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Get.theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
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
                              Get.to(PropertyUnitForm(), arguments: property);
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
                                        Text(property['property_name'] ?? 'Unnamed Property', style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(property['unit_number'].toString(), style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        Text('Property ID: ${property['id'] ?? 'N/A'}', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),

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
                                                  const Icon(Icons.category, size: 12, color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: Get.width * 0.22,
                                                      ),
                                                      child: Text(
                                                        property['floor'].toString(),
                                                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.blue[800]),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 6),

                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.person, size: 12, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: Get.width * 0.22,
                                                      ),
                                                      child: Text(
                                                        property['is_available'].toString(),
                                                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.green[800]),
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
              Get.to(PropertyUnitForm(), arguments: {});
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(
              Icons.add_home_work_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
