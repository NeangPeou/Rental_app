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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    firstMainThemeColor.withOpacity(0.1),
                    firstMainThemeColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Get.theme.cardColor,
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const SpinKitCircle(
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "loading".tr,
              style: Get.textTheme.bodyMedium
            ),
          ],
        ),
      ),
    );
  }
}

