import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/page/owner/form/propertyForm.dart';
import 'package:get/get.dart';
import 'package:frontend_rental/controller/property_controller.dart';
import 'package:frontend_rental/services/propertyService.dart';
import 'package:frontend_rental/shared/loading.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final PropertyService _propertyService = PropertyService();
  final PropertyController propertyController = Get.put(PropertyController());
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() :
    Scaffold(
      body: Obx(() {
        if (propertyController.properties.isEmpty) {
          return const Center(child: Text("No properties found."));
        }

        return RefreshIndicator(
          onRefresh: () => _refreshData(),
          child: ListView.builder(
            itemCount: propertyController.properties.length,
            itemBuilder: (context, index) {
              final property = propertyController.properties[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: EdgeInsets.all(8),
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
                    Get.to(PropertyForm(), arguments: property);
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                        child: Image.asset(
                          'assets/app_icon/sw_logo.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(property['name'] ?? 'Unnamed Property', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(property['address'] ?? 'No address', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              Text('Property ID: ${property['id'] ?? 'N/A'}', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),

                              const SizedBox(height: 6),
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
    );
  }
}