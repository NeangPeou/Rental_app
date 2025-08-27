import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend_rental/shared/constants.dart';
import 'package:get/get.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Get.theme.scaffoldBackgroundColor),
      child: const Center(
        child: SpinKitFadingCircle(color: firstMainThemeColor, size: 50.0),
      ),
    );
  }
}
