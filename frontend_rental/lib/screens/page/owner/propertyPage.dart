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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(property['name'] ?? 'Unnamed'),
                  subtitle: Text(property['address'] ?? 'No address'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Get.to(PropertyForm(), arguments: property);
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {

                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed('/property-detail', arguments: property);
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}