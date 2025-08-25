// screens/user_detail.dart
import 'package:flutter/material.dart';
import 'package:frontend_admin/models/user_model.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class UserDetail extends StatelessWidget {
  const UserDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Expect user data to be passed via Get.arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final UserModel user = UserModel(
      id: args['id']?.toString(),
      userName: args['userName']?.toString() ?? '',
      userID: args['userID']?.toString(),
      password: '', // Not displayed for security
      phoneNumber: args['phoneNumber']?.toString() ?? '',
      passport: args['passport']?.toString(),
      idCard: args['idCard']?.toString(),
      address: args['address']?.toString(),
      gender: args['gender']?.toString() ?? 'Male',
      status: args['status']?.toString(),
    );

    // Map gender to icons for display
    final Map<String, IconData> genderIcons = {
      'Male': Icons.male,
      'Female': Icons.female,
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400, 
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withAlpha(100)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'userdetail'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Helper.sampleTextField(
                context: context,
                controller: TextEditingController(text: user.userName),
                labelText: 'Username'.tr,
                prefixIcon: const Icon(Icons.person),
                enabled: false,
              ),
              const SizedBox(height: 10),
              Helper.sampleTextField(
                context: context,
                controller: TextEditingController(text: user.phoneNumber),
                labelText: 'PhoneNumber'.tr,
                prefixIcon: const Icon(Icons.phone),
                enabled: false,
              ),
              if (user.passport != null && user.passport!.isNotEmpty)
                const SizedBox(height: 10),
              if (user.passport != null && user.passport!.isNotEmpty)
                Helper.sampleTextField(
                  context: context,
                  controller: TextEditingController(text: user.passport),
                  labelText: 'Passport'.tr,
                  prefixIcon: const Icon(Icons.badge),
                  enabled: false,
                ),
              if (user.idCard != null && user.idCard!.isNotEmpty)
                const SizedBox(height: 10),
              if (user.idCard != null && user.idCard!.isNotEmpty)
                Helper.sampleTextField(
                  context: context,
                  controller: TextEditingController(text: user.idCard),
                  labelText: 'IDCard'.tr,
                  prefixIcon: const Icon(Icons.credit_card),
                  enabled: false,
                ),
              if (user.address != null && user.address!.isNotEmpty)
                const SizedBox(height: 10),
              if (user.address != null && user.address!.isNotEmpty)
                Helper.sampleTextField(
                  context: context,
                  controller: TextEditingController(text: user.address),
                  labelText: 'Address'.tr,
                  prefixIcon: const Icon(Icons.home),
                  enabled: false,
                ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withAlpha(50),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_reaction,
                      color: Theme.of(context).colorScheme.secondary.withAlpha(130),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'gender'.tr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      genderIcons[user.gender] ?? Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(user.gender!.tr, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (user.status != null && user.status!.isNotEmpty)
                const SizedBox(height: 10),
              if (user.status != null && user.status!.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withAlpha(50),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.secondary.withAlpha(130),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'status'.tr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: user.status == 'Active'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.status!.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('back'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
