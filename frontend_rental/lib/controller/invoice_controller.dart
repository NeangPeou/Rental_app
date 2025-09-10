import 'package:get/get.dart';

class InvoiceController extends GetxController {
  final RxList<Map<String, dynamic>> activeLeases = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> invoices = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allInvoices = [];

  void setListLeases(List<Map<String, dynamic>> data) {
    activeLeases.assignAll(data);
  }
  /// Set full list of invoices
  void setListInvoices(List<Map<String, dynamic>> data) {
    allInvoices.clear();
    allInvoices.addAll(data);
    invoices.assignAll(data);
  }

  /// Add new invoice
  void addInvoice(Map<String, dynamic> invoice) {
    allInvoices.insert(0, invoice);
    invoices.insert(0, invoice);
  }

  /// Update existing invoice
  void updateInvoice(Map<String, dynamic> updatedInvoice) {
    final int index = invoices.indexWhere((inv) => inv['id'] == updatedInvoice['id']);
    final int allIndex = allInvoices.indexWhere((inv) => inv['id'] == updatedInvoice['id']);

    if (index != -1) invoices[index] = updatedInvoice;
    if (allIndex != -1) allInvoices[allIndex] = updatedInvoice;

    invoices.refresh();
  }

  /// Remove invoice by ID
  void removeInvoice(String id) {
    invoices.removeWhere((inv) => inv['id'] == id);
    allInvoices.removeWhere((inv) => inv['id'] == id);
  }
}
