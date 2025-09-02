import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../controller/payment_controller.dart';
import '../models/error.dart';
import '../models/payment_model.dart';

class PaymentService {
  final String baseUrl = dotenv.env['API_URL']!;

  /// CREATE Payment
  Future<ErrorModel> createPayment(PaymentModel payment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payment.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<PaymentController>().addPayment(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Payment created');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create payment');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// READ all Payments
  Future<ErrorModel> getAllPayments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final payments = List<Map<String, dynamic>>.from(jsonList);
        Get.find<PaymentController>().setListPayments(payments);
        return ErrorModel(isError: false, code: 'Success', message: 'Payments fetched');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// UPDATE Payment
  Future<ErrorModel> updatePayment(String id, PaymentModel payment) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/payment/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payment.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.find<PaymentController>().updatePayment(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Payment updated');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to update payment');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// DELETE Payment
  Future<ErrorModel> deletePayment(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/payment/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.find<PaymentController>().removePayment(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Payment deleted');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to delete payment');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }
}
