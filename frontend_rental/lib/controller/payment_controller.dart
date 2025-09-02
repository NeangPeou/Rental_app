import 'package:get/get.dart';

class PaymentController extends GetxController {
  final RxList<Map<String, dynamic>> payments = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allPayments = [];

  /// Set full list of payments
  void setListPayments(List<Map<String, dynamic>> data) {
    allPayments.clear();
    allPayments.addAll(data);
    payments.assignAll(data);
  }

  /// Add new payment
  void addPayment(Map<String, dynamic> payment) {
    allPayments.insert(0, payment);
    payments.insert(0, payment);
  }

  /// Update existing payment
  void updatePayment(Map<String, dynamic> updatedPayment) {
    final int index = payments.indexWhere((p) => p['id'] == updatedPayment['id']);
    final int allIndex = allPayments.indexWhere((p) => p['id'] == updatedPayment['id']);

    if (index != -1) payments[index] = updatedPayment;
    if (allIndex != -1) allPayments[allIndex] = updatedPayment;

    payments.refresh(); // make sure UI is updated
  }

  /// Remove payment by ID
  void removePayment(String id) {
    payments.removeWhere((p) => p['id'] == int.tryParse(id));
    allPayments.removeWhere((p) => p['id'] == int.tryParse(id));
  }
}
