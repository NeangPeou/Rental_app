import 'package:flutter/material.dart';
import 'package:frontend_rental/models/error.dart';
import 'package:frontend_rental/screens/page/owner/form/invoiceForm.dart';
import 'package:frontend_rental/services/invoice_service.dart';
import 'package:frontend_rental/utils/helper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/invoice_controller.dart';
import '../../../shared/loading.dart';

class Invoice extends StatefulWidget {
  const Invoice({super.key});

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  final InvoiceController invoiceController = Get.put(InvoiceController());
  final InvoiceService invoiceService = InvoiceService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    ErrorModel errorModel = await invoiceService.getInvoices();
    if (errorModel.isError == true) {
      Get.back();
    }
    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupInvoices(List<Map<String, dynamic>> invoices) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var invoice in invoices) {
      final date = DateTime.parse(invoice['month']);
      final key = DateFormat.yMMMM().format(date); // e.g. September 2025

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(invoice);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: Loading())
        : Scaffold(
      appBar: Helper.sampleAppBar('invoice'.tr, context, null),
      body: Obx(() {
        final invoices = invoiceController.invoices;
        if (invoices.isEmpty) {
          return Center(child: Text('No invoice found'));
        }

        final groupedInvoices = _groupInvoices(invoices);

        return ListView(
          children: groupedInvoices.entries.map((entry) {
            return ExpansionTile(
              title: Text("📅 ${entry.key}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: entry.value.map((invoice) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text("🔵 Invoice #${invoice['id']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 Renter: ${invoice['renter_name']}"),
                        Text("🏠 Unit: ${invoice['unit_number']}"),
                        Text("💰 Total: \$${invoice['total']}"),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text("🏷️ Status: "),
                            _statusBadge(invoice['status']),
                          ],
                        )
                      ],
                    ),
                    onTap: () {
                      _showInvoiceDetail(invoice);
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(InvoiceForm(), arguments: {});
        },
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: const Icon(Icons.add_chart_rounded, color: Colors.white),
      ),
    );
  }

  void _showInvoiceDetail(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text("Invoice #${invoice['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              _buildRow("Month", invoice['month']),
              _buildRow("Renter", invoice['renter_name']),
              _buildRow("Unit", invoice['unit_number']),
              _buildRow("Rent", "\$${invoice['rent']}"),
              _buildRow("Utility", "\$${invoice['utility']}"),
              _buildRow("Total", "\$${invoice['total']}", isBold: true),
              _buildRow("Status", invoice['status'].toString().capitalizeFirst ?? ""),
              const SizedBox(height: 16),
              const Text("Utilities Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...List.generate(invoice['utilities']?.length ?? 0, (i) {
                final util = invoice['utilities'][i];
                return _buildRow(
                  "${util['utility_type_id']} (${util['billing_type']})",
                  util['cost'] != null ? "\$${util['cost']}" : "-",
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label = status.capitalizeFirst ?? '';

    switch (status) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
