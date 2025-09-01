import 'package:flutter/material.dart';
import 'package:frontend_rental/screens/page/owner/form/paymentForm.dart';
import 'package:get/get.dart';
import '../../../shared/loading.dart';
import '../../../utils/helper.dart';
class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  void filter(String query) {
    // final PropertyController controller = Get.find<PropertyController>();
    //
    // if (query.isEmpty) {
    //   controller.properties.assignAll(controller.allProperties);
    // } else {
    //   controller.properties.assignAll(
    //     controller.allProperties.where((property) {
    //       final queryLower = query.toLowerCase();
    //
    //       return (
    //           (property['id'] ?? '').toString().toLowerCase().contains(queryLower)) ||
    //           (property['name'] ?? '').toString().toLowerCase().contains(queryLower) ||
    //           (property['address'] ?? '').toString().toLowerCase().contains(queryLower) ||
    //           (property['type_name'] ?? '').toString().toLowerCase().contains(queryLower) ||
    //           (property['owner_name'] ?? '').toString().toLowerCase().contains(queryLower);
    //     }).toList(),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('payment', context, null),
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                  filter(value);
                },
                prefixIcon: Icon(Icons.search),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Payment $index'),
                        subtitle: Text('Payment $index'),
                        trailing: Text('Payment $index'),
                      );
                    },
                  )
              )
            ],
          ),
        )
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
              Get.to(PaymentForm(), arguments: {});
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(
              Icons.add_card_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
