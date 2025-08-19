import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend_admin/shared/constants.dart';
import 'package:get/get.dart';

class Helper {
  static AppBar sampleAppBar(String title,BuildContext context, String? logoImg) {
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      leading: logoImg != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: ClipOval(child: Image.asset(logoImg)),
            )
          : null,
    );
  }

  static Widget sampleTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
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
            label: RichText(
              text: TextSpan(
                text: labelText,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
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
            suffixIcon: showClearIcon
                ? IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Get.theme.cardColor,
                      radius: 10,
                      child: const Icon(Icons.clear_rounded, size: 15),
                    ),
                    onPressed: () {
                      controller.clear();
                      if (onChanged != null) onChanged('');
                    },
                  )
                : suffixIcon,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              borderSide:
                  BorderSide(color: theme.colorScheme.onSecondaryContainer),
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
