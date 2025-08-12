import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  List<Color> colors = [
    Color.fromRGBO(178, 0, 0, 1.0),       // Darker Red
    Color.fromRGBO(0, 178, 0, 1.0),       // Darker Green
    Color.fromRGBO(0, 0, 178, 1.0),       // Darker Blue
    Color.fromRGBO(178, 178, 0, 1.0),     // Darker Yellow
    Color.fromRGBO(139, 14, 93, 1.0),     // Darker Magenta
    Color.fromRGBO(178, 115, 0, 1.0),     // Darker Orange
    Color.fromRGBO(128, 0, 128, 1.0),   // Purple
    Color.fromRGBO(0, 128, 128, 1.0),   // Teal
    Color.fromRGBO(128, 128, 0, 1.0),   // Olive
  ];

  @override
  void initState() {
    super.initState();
    title = Get.arguments ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16 ,vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Contrast", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Obx(() => Text("${(settingController.contrast.value * 100).toInt()}%")),
                  ],
                ),
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoSlider(
                              min: 50,
                              max: 150,
                              divisions: 50,
                              value: settingController.contrast.value * 100,
                              activeColor: settingController.selectedColor.value,
                              thumbColor: Colors.white,
                              onChanged: (val) {
                                settingController.setContrast(val / 100);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      settingController.setContrast(1.0);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                    ),
                    child: Text(
                      "Reset to default",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text("Adjust the contrast between foreground and background colors", style: Theme.of(context).textTheme.bodySmall),

          SizedBox(height: 30),
          Container(
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16 ,vertical: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Saturation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Obx(() => Text("${(settingController.saturation.value * 100).toInt()}%")),
                  ],
                ),
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoSlider(
                              min: 0,
                              max: 150,
                              divisions: 50,
                              value: settingController.saturation.value * 100,
                              activeColor: settingController.selectedColor.value,
                              thumbColor: Colors.white,
                              onChanged: (val) {
                                settingController.setSaturation(val / 100);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      settingController.setSaturation(1.0);
                    },
                    child: Text(
                      "Reset to default",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text("Reduce the saturation of colors within the application, for those with color sensitivities. This does not effect the saturation of images, video, role colors or other user-provided content by default.", style: Theme.of(context).textTheme.bodySmall),

          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.only(top: 16, left: 10, right: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Change Color"),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: colors.length + 1, // +1 for the color picker item
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () async {
                            Color pickedColor = settingController.selectedColor.value;
                            Get.defaultDialog(
                              radius: 10,
                              title: 'Pick a color',
                              titlePadding: EdgeInsets.only(top: 20, bottom: 10),
                              contentPadding: EdgeInsets.symmetric(horizontal: 30),
                              content: SingleChildScrollView(
                                padding: EdgeInsets.zero,
                                child: ColorPicker(
                                    pickerColor: pickedColor,
                                    onColorChanged: (color) {
                                      pickedColor = color;
                                    },
                                    onHsvColorChanged: (hsvColor) {
                                      pickedColor = hsvColor.toColor();
                                      settingController.setColor(pickedColor);
                                    }
                                ),
                              ),
                              confirm: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Obx(() => ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: settingController.selectedColor.value,
                                      elevation: 0.0
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cancel",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ),
                                )),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: settingController.selectedColor.value == Colors.grey[850] ? Colors.grey : settingController.selectedColor.value,
                                width: 1,
                              ),
                            ),
                            child: const Icon(Icons.color_lens, size: 30),
                          ),
                        );
                      }

                      final color = colors[index - 1];
                      final isSelected = settingController.selectedColor.value == color;

                      return GestureDetector(
                        onTap: () {
                          settingController.setColor(color);
                        },
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
