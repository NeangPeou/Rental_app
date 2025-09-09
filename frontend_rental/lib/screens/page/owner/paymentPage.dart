import 'package:flutter/material.dart';
import 'package:frontend_rental/controller/payment_controller.dart';
import 'package:frontend_rental/screens/page/owner/form/paymentForm.dart';
import 'package:frontend_rental/services/payment_service.dart';
import 'package:get/get.dart';
import '../../../shared/loading.dart';
import '../../../utils/helper.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isLoading = true;
  final PaymentController paymentController = Get.put(PaymentController());
  final TextEditingController searchController = TextEditingController();
  final PaymentService paymentService = PaymentService();

  void filter(String query) {
    final PaymentController controller = Get.find<PaymentController>();

    if (query.isEmpty) {
      controller.payments.assignAll(controller.allPayments);
    } else {
      controller.payments.assignAll(
        controller.allPayments.where((property) {
          final queryLower = query.toLowerCase();

          return (
              (property['payment_date'] ?? '').toString().toLowerCase().contains(queryLower)) ||
              (property['amount_paid'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['payment_method_id'] ?? '').toString().toLowerCase().contains(queryLower) ||
              (property['receipt_url'] ?? '').toString().toLowerCase().contains(queryLower);
        }).toList(),
      );
    }
  }

  Future<void> _refreshData() async {
    await paymentService.getAllPayments();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Helper.sampleAppBar('payments'.tr, context, null),
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
                child: Obx(() {
                  if (paymentController.payments.isEmpty) {
                    return Helper.emptyData();
                  }
                  return RefreshIndicator(
                    onRefresh: () => _refreshData(),
                    child: ListView.builder(
                      itemCount: paymentController.payments.length,
                      itemBuilder: (context, index) {
                        final property = paymentController.payments[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Get.theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Get.to(PaymentForm(), arguments: property);
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                                  child: Image.asset(
                                    'assets/app_icon/sw_logo.png',
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // IconButton(onPressed: (){
                                        //   paymentService.deletePayment(property['id']);
                                        // }, icon: Icon(Icons.delete_outline, color: Colors.red)),
                                        Text(property['property_name'] ?? 'Unknown', style: Get.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            const Icon(Icons.category, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(property['unit_number'].toString(), style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        Text('${'amount_paid'.tr}: \$${property['amount_paid'] ?? 'N/A'}', style: Get.textTheme.bodySmall, overflow: TextOverflow.ellipsis),

                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.category, size: 12, color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: Get.width * 0.22,
                                                      ),
                                                      child: Text(
                                                        property['payment_date'].toString(),
                                                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.blue[800]),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 6),

                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.person, size: 12, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: Get.width * 0.22,
                                                      ),
                                                      child: Text(
                                                        property['renter_name'].toString(),
                                                        style: Get.textTheme.bodySmall?.copyWith(color: Colors.green[800]),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
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
