import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend_rental/shared/constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../screens/bottomNavigationBar/setting_pages/my_account.dart';

class Helper {
   static String defaultDateFormat = 'yyyy-MM-dd'; // Default format, can be changed

  // Format a DateTime object to a string using the specified or default format
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? defaultDateFormat);
    return formatter.format(date);
  }

  // Parse a date string to a DateTime object using the specified or default format
  static DateTime parseDate(String dateString, {String? format}) {
    final formatter = DateFormat(format ?? defaultDateFormat);
    return formatter.parse(dateString);
  }
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
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool passwordType = false,
    void Function(String)? onChanged,
    bool isRequired = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final showClearIcon = enabled && !passwordType && value.text.isNotEmpty;

        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
          enabled: enabled,
          onTap: onTap,
          readOnly: readOnly,
        );
      },
    );
  }

  static Widget sampleDropdownSearch({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required String labelText,
    required TextEditingController controller,
    required String displayKey,
    required String idKey,
    String? selectedId,
    bool isRequired = false,
    String? Function(Map<String, dynamic>?)? validator,
    void Function(Map<String, dynamic>?)? onChanged,
    String? hintText,
    double? maxHeight,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? dropDownPrefixIcon,
    Widget? dropDownSuffixIcon,
  }) {
    final theme = Theme.of(context);

    return DropdownSearch<Map<String, dynamic>>(
      items: (String filter, _) {
        if (filter.isEmpty) return items.toList();
        return items.where((item) => (item[displayKey] as String).toLowerCase().contains(filter.toLowerCase())).toList();
      },
      selectedItem: selectedId != null ? items.firstWhereOrNull((e) => e[idKey].toString() == selectedId) : null,
      itemAsString: (item) => item[displayKey] ?? 'Unknown',
      compareFn: (item1, item2) => item1[idKey] == item2[idKey],
      onChanged: (selected) {
        if (selected != null) {
          controller.text = selected[idKey].toString();
        }
        if (onChanged != null) onChanged(selected);
      },
      validator: validator ?? (value) {
        if (isRequired && value == null) {
          return labelText;
        }
        return null;
      },
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          prefixIcon: dropDownPrefixIcon,
          suffixIcon: dropDownSuffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          label: RichText(
            text: TextSpan(
              text: labelText,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              children: isRequired ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ] : [],
            ),
          ),
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
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          style: Get.textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: hintText ?? '${'search'.tr} ...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        constraints: BoxConstraints(maxHeight: (maxHeight ?? 250)),
        showSelectedItems: true,
        menuProps: MenuProps(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
        ),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isSelected ? Colors.teal.withOpacity(0.2) : Colors.transparent,
            child: Text(
              item[displayKey].toString(),
              style: TextStyle(
                fontSize: Get.textTheme.bodyMedium?.fontSize,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isDisabled ? Colors.grey : (isSelected ? Colors.teal : Get.textTheme.bodyMedium?.color),
              ),
            ),
          );
        },
        loadingBuilder: (context, _) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SpinKitFadingCircle(
                color: firstMainThemeColor,
                size: 40.0,
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget sampleRadioGroup({
    required BuildContext context,
    required RxString selectedValue,
    required List<String> options,
    required String labelText,
    String? Function(String?)? validator,
    Icon? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final Map<String, IconData> genderIcons = {
      'Male': Icons.male,
      'Female': Icons.female,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      labelText.tr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ...options.map(
                  (option) => RadioListTile<String>(
                    title: Text(option.tr),
                    value: option,
                    groupValue: selectedValue.value,
                    onChanged: (value) {
                      if (value != null) {
                        selectedValue.value = value;
                      }
                    },
                    secondary: Icon(
                      genderIcons[option],
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget smallSearchField({
    required BuildContext context,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? hintText,
  }) {
    return Container(
      height: 40, // compact height
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(100),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Get.textTheme.bodySmall,
        decoration: InputDecoration(
          hintText: hintText ?? 'search'.tr,
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          isDense: true, // makes it compact
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
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

  static Future<bool?> showDeleteConfirmationDialog(
    BuildContext context, String itemId) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              Text(
                'confirm_delete'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            'are_you_sure_delete_lease'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('delete'.tr),
            ),
          ],
        );
      },
    );
  }
  static void closeLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

   static void showSnackbar({
     required String title,
     required String message,
     SnackPosition position = SnackPosition.BOTTOM,
     Color backgroundColor = Colors.black87,
     Color textColor = Colors.white,
     IconData? icon,
     Duration duration = const Duration(seconds: 3),
     EdgeInsets margin = const EdgeInsets.all(10),
     double borderRadius = 8.0,
   }) {
     Get.snackbar(
       title,
       message,
       snackPosition: position,
       backgroundColor: backgroundColor,
       colorText: textColor,
       icon: icon != null ? Icon(icon, color: textColor) : null,
       duration: duration,
       margin: margin,
       borderRadius: borderRadius,
     );
   }

   static void successSnackbar(String message) {
     showSnackbar(
       title: "success".tr,
       message: message,
       backgroundColor: Colors.green,
       icon: Icons.check_circle,
     );
   }

   static void errorSnackbar(String message) {
     showSnackbar(
       title: "failed".tr,
       message: message,
       backgroundColor: Colors.red,
       icon: Icons.error,
     );
   }
}
