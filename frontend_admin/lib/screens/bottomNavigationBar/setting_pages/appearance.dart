import 'package:flutter/material.dart';
import 'package:frontend_admin/controller/setting_controller.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class Appearance extends StatefulWidget {
  const Appearance({super.key});

  @override
  State<Appearance> createState() => _AppearanceState();
}

class _AppearanceState extends State<Appearance> {
  late String title;
  SettingController settingController = Get.put(SettingController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    title = Get.arguments ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: Get.height * .2,
            padding: EdgeInsets.symmetric(horizontal: 16 ,vertical: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Contrast", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Obx(() => Text("${(settingController.contrast.value * 100).toInt()}%")),
                  ],
                ),
                Obx(() => Slider(
                  min: 50,
                  max: 150,
                  divisions: 10,
                  value: settingController.contrast.value * 100,
                  label: "${(settingController.contrast.value * 100).toInt()}%",
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.grey.shade400,
                  onChanged: (val) {
                    settingController.setContrast(val / 100);
                  },
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: Get.height,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar("title", "message");
                    },
                    child: Text("Reset to default", style: Theme.of(context).textTheme.labelLarge),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text("Adjust the contrast between foreground and background colors", style: Theme.of(context).textTheme.bodySmall),

          SizedBox(height: 30),
          Container(
            height: Get.height * .2,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Saturation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Obx(() => Text("${(settingController.saturation.value * 100).toInt()}%")),
                  ],
                ),
                Obx(() => Slider(
                  min: 50,
                  max: 150,
                  divisions: 10,
                  value: settingController.saturation.value * 100,
                  label: "${(settingController.saturation.value * 100).toInt()}%",
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.grey.shade400,
                  onChanged: (val) {
                    settingController.setSaturation(val / 100);
                  },
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: Get.height,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar("title", "message");
                    },
                    child: Text("Reset to default", style: Theme.of(context).textTheme.labelLarge),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text("Reduce the saturation of colors within the application, for those with color sensitivities. This does not effect the saturation of images, video, role colors or other user-provided content by default.", style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
