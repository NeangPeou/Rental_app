import 'package:flutter/material.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:frontend_admin/services/type_service.dart';
import 'package:frontend_admin/shared/message_dialog.dart';
import 'package:get/get.dart';
import '../../controller/type_controller.dart';
import '../../shared/loading.dart';
import '../../utils/helper.dart';
class BuildingType extends StatefulWidget {
  const BuildingType({super.key});

  @override
  State<BuildingType> createState() => _BuildingTypeState();
}

class _BuildingTypeState extends State<BuildingType> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  final types = Get.find<TypeController>().listTypes;
  final TypeService _typeService = TypeService();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllTypes();
  }

  Future<void> getAllTypes() async {
    await _typeService.getAllTypes();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    getAllTypes();
  }

  void filterTypes(String query) {
    final TypeController controller = Get.find<TypeController>();

    if (query.isEmpty) {
      controller.listTypes.assignAll(controller.allTypes);
    } else {
      controller.listTypes.assignAll(
        controller.allTypes.where((type) =>
        (type['type_code'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
            (type['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(body: Center(child: Loading())) : Scaffold(
      appBar: Helper.sampleAppBar("property_type".tr, context, null),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                filterTypes(value);
              },
              prefixIcon: Icon(Icons.search),
            ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
              onRefresh: _refreshData,
              child: Obx(() {
                if (types.isEmpty) {
                  return Center(child: Text('no_types_found'.tr));
                }

                return ListView.builder(
                  itemCount: types.length,
                  itemBuilder: (context, index) {
                    final type = types[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100), width: 1),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          leading: const Icon(Icons.apartment_rounded, size: 35, color: Colors.blueAccent),
                          title: Text(
                            '${"type_name".tr}: ${type['name'] ?? ''}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${"type_code".tr}: ${type['typeCode'] ?? ''}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  showBottomSheet(type['id'], type['typeCode'], type['name']);
                                },
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async{
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
                                            Text('AreYouSureDelete'.tr.replaceFirst('{userName}', type['typeCode']), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
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
                                                      Helper.showLoadingDialog(context);
                                                      ErrorModel errorModel = await _typeService.deleteType(type['id']);
                                                      Helper.closeLoadingDialog(context);
                                                      if(errorModel.isError){
                                                        MessageDialog.showMessage('information'.tr, 'delete_failed', context);
                                                      }
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
                );
              }),
                  ),
            ),
          ],
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
              showBottomSheet(null, null, null);
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(
              Icons.person_add_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(String? id, String? typeCode, String? typeName) {
    codeController.text = typeCode ?? '';
    nameController.text = typeName ?? '';
    Get.bottomSheet(
      SafeArea(
        bottom: false,
        maintainBottomViewPadding: true,
        child: StatefulBuilder(
            builder: (context, setState){
              return Container(
                height: Get.height * .7,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 15),
                decoration: BoxDecoration(
                  color: Get.theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(id != null ? 'edit_property_type'.tr : 'add_property_type'.tr, style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              SizedBox(height: 10),
                              Text(id != null ? 'edit_property_type_description'.tr : 'add_property_type_description'.tr, style: Get.textTheme.bodyMedium, textAlign: TextAlign.center),
                              const SizedBox(height: 30),
                              Helper.sampleTextField(
                                context: context,
                                controller: codeController,
                                labelText: 'type_code'.tr,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'enter_type_code'.tr;
                                  return null;
                                },
                                onChanged: (_) {},
                                prefixIcon: Icon(Icons.code),
                                passwordType: true,
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              Helper.sampleTextField(
                                context: context,
                                controller: nameController,
                                labelText: 'type_name'.tr,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'enter_type_name'.tr;
                                  return null;
                                },
                                onChanged: (_) {},
                                prefixIcon: Icon(Icons.menu_book_rounded),
                                passwordType: true,
                                isRequired: true,
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: Get.height,
                                child: ElevatedButton(
                                    onPressed: ()async {
                                      if (_formKey.currentState!.validate()) {
                                        Helper.showLoadingDialog(context);
                                        ErrorModel errorModel;
                                        if(id == null){
                                          errorModel = await _typeService.createType(context, codeController.text, nameController.text);
                                        }else{
                                          errorModel = await _typeService.updateType(id, codeController.text, nameController.text);
                                        }
                                        Helper.closeLoadingDialog(context);
                                        if (errorModel.isError == false){
                                          Get.back();
                                          Get.showSnackbar(
                                            GetSnackBar(
                                              messageText: const SizedBox.shrink(),
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Get.theme.scaffoldBackgroundColor,
                                              snackStyle: SnackStyle.FLOATING,
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                                              borderRadius: 8,
                                              duration: const Duration(seconds: 3),
                                              isDismissible: true,
                                              titleText: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.save, size: 25, color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(id == null ? 'created_successfully'.tr : 'updated_successfully'.tr, style: Get.textTheme.titleMedium),
                                                ],
                                              ),
                                            ),
                                          );
                                        }else {
                                          String errorMessage = errorModel.message!.toLowerCase();

                                          if (errorMessage.contains('already exists')) {
                                            MessageDialog.showMessage('information'.tr, 'type_already_exists'.tr, context);
                                          } else {
                                            MessageDialog.showMessage('information'.tr, id == null ? 'create_failed'.tr : 'update_failed'.tr, context);
                                          }
                                        }
                                      }
                                    },
                                    child: Text(id == null ? 'save'.tr : 'update'.tr)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
        ),
      ),
      isScrollControlled: false,
    );
  }
}