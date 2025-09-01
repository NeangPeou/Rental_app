import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/property_controller.dart';
import '../models/error.dart';
import '../models/lease_model.dart';
import 'package:get/get.dart';

class LeaseService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<ErrorModel> createLease(LeaseModel leaseData) async {
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
        Uri.parse('$baseUrl/api/create-lease'),
        body: jsonEncode(leaseData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.find<PropertyController>().addLease(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Lease created successfully');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create lease');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> getAllLeases() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-all-leases'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<Map<String, dynamic>> leases = List<Map<String, dynamic>>.from(jsonList);
        Get.find<PropertyController>().setLeases(leases);
        return ErrorModel(isError: false, code: 'Success', message: 'Leases fetched');
      } else {
        throw Exception('Failed to fetch leases');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> updateLease(String id, LeaseModel leaseData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/update-lease/$id'),
        body: jsonEncode(leaseData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<PropertyController>().updateLease(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Lease updated');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to update lease');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> deleteLease(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/delete-lease/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.find<PropertyController>().removeLease(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Lease deleted');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['detail'] ?? 'Failed to delete lease');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> getAllRenters() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-all-renters'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<Map<String, dynamic>> renters = List<Map<String, dynamic>>.from(jsonList);
        Get.find<PropertyController>().setRenters(renters);
        return ErrorModel(isError: false, code: 'Success', message: 'Renters fetched');
      } else {
        throw Exception('Failed to fetch renters');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }
}