import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/page/owner/form/propertyForm.dart';
import 'package:get/get.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/services/property_service.dart';
import 'package:frontend_rental/shared/loading.dart';
import '../../../utils/helper.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final PropertyService _propertyService = PropertyService();
  final PropertyController propertyController = Get.put(PropertyController());
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    await _propertyService.getAllProperties();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    fetchProperties();
  }

  void filter(String query) {
    final PropertyController controller = Get.find<PropertyController>();

    if (query.isEmpty) {
      controller.properties.assignAll(controller.allProperties);
    } else {
      controller.properties.assignAll(
        controller.allProperties.where((property) {
          final queryLower = query.toLowerCase();

          return (
              (property['id'] ?? '').toString().toLowerCase().contains(queryLower)) ||
              (property['name'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['address'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['type_name'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['owner_name'] ?? '').toString().toLowerCase().contains(queryLower);
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() :
    Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('property'.tr, context, null),
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
                  if (propertyController.properties.isEmpty) {
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
                      itemCount: propertyController.properties.length,
                      itemBuilder: (context, index) {
                        final property = propertyController.properties[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Get.theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
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
                              Get.to(PropertyForm(), arguments: property);
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
                                        Text(property['name'] ?? 'Unnamed Property', style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(property['address'] ?? 'No address', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        Text('${'property_id'.tr}: ${property['id'] ?? 'N/A'}', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),

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
                                                        property['type_name'] ?? 'N/A',
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
                                                        property['owner_name'] ?? 'N/A',
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
              Get.to(PropertyForm(), arguments: {});
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