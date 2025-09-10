import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/invoice_controller.dart';
import '../models/error.dart';

class InvoiceService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<ErrorModel> getActiveLeases() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/get_active_leases'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final leases = List<Map<String, dynamic>>.from(jsonList);
        Get.find<InvoiceController>().setListLeases(leases);
        return ErrorModel(isError: false, code: 'Success', message: 'Leases fetched');
      } else {
        throw Exception('Failed to fetch');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> createInvoice(String leaseId, String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(
          isError: true,
          code: 'unauthorized',
          message: 'Access token not found',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/create-invoice'),
        body: jsonEncode({
          'lease_id': leaseId,
          'month': date
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ErrorModel(isError: false, code: 'Success', message: 'created successfully');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> getInvoices() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-invoices'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final invoices = List<Map<String, dynamic>>.from(jsonList);
        Get.find<InvoiceController>().setListInvoices(invoices);
        return ErrorModel(isError: false, code: 'Success', message: 'Leases fetched');
      } else {
        throw Exception('Failed to fetch');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }
}