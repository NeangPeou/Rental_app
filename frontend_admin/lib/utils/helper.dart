import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting_pages/my_account.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';

class Helper {
  static AppBar sampleAppBar(String title,BuildContext context, String? logoImg, {VoidCallback? onLogoTap}) {
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      actions: [
        if (logoImg != null)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onLogoTap ?? () {
              Get.to(() => MyAccount(), arguments: {'title': 'my_account'.tr});
            },
            child: ClipOval(
              child: Image.asset(
                logoImg,
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }

  static Widget sampleTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool passwordType = false,
    void Function(String)? onChanged,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final showClearIcon = !passwordType && value.text.isNotEmpty;

        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10, right: 10),
            label: RichText(
              text: TextSpan(
                text: labelText,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                children: isRequired
                    ? [
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
            suffixIcon: showClearIcon ?
                IconButton(
                    icon: CircleAvatar(backgroundColor: Get.theme.cardColor, radius: 10, child: const Icon(Icons.clear_rounded, size: 15)),
                    onPressed: () {
                      controller.clear();
                      if (onChanged != null) onChanged('');
                    },
                  )
                : suffixIcon,
            prefixIcon: prefixIcon,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
          validator: validator,
          style: theme.textTheme.bodyLarge,
          onChanged: onChanged,
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: SpinKitFadingCircle(color: firstMainThemeColor, size: 50.0),
        );
      },
    );
  }

  static void closeLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
