import 'package:flutter/material.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:get/get.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  late String title;

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
      body: Center(child: Text("datsddsa"),),
    );
  }
}
