import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/models/inventory_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/inventory_controller.dart';
import '../models/error.dart';
import 'package:get/get.dart';

class InventoryService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<ErrorModel> createInventory(InventoryModel inventoryData) async {
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
        Uri.parse('$baseUrl/api/create-inventory'),
        body: jsonEncode(inventoryData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.find<InventoryController>().addInventory(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Inventory item created successfully');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create inventory item');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> getAllInventory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-all-inventory'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<Map<String, dynamic>> inventory = List<Map<String, dynamic>>.from(jsonList);
        Get.find<InventoryController>().setInventory(inventory);
        return ErrorModel(isError: false, code: 'Success', message: 'Inventory fetched');
      } else {
        throw Exception('Failed to fetch inventory');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> updateInventory(String id, InventoryModel inventoryData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/update-inventory/$id'),
        body: jsonEncode(inventoryData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<InventoryController>().updateInventory(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Inventory item updated');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to update inventory item');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  Future<ErrorModel> deleteInventory(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/delete-inventory/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.find<InventoryController>().removeInventory(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Inventory item deleted');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['detail'] ?? 'Failed to delete inventory item');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }
}