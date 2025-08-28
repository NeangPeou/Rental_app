import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_admin/controller/type_controller.dart';
import 'package:frontend_admin/models/error.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TypeService {
  final String baseUrl = dotenv.env['API_URL']!;

  /// Create
  Future<ErrorModel> createType(BuildContext context, String typeCode, String typeName) async {
    try {
      TypeController typeController = Get.put(TypeController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }

      final res = await http.post(
        Uri.parse('$baseUrl/api/create-type'),
        body: jsonEncode({
          'type_code': typeCode,
          'name': typeName,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      Map<String, dynamic>? response = jsonDecode(res.body);
      if (res.statusCode == 200) {
        typeController.addType(response!);
        return ErrorModel(isError: false, code: 'Success', message: 'Type created successfully');
      }else{
        throw Exception(response!['detail'] ?? 'Failed to create type');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information', message: e.toString());
    }
  }

  /// Read
  Future<ErrorModel> getAllTypes() async {
    try {
      TypeController typeController = Get.put(TypeController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/getalltype'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final List<dynamic>? body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> types = List<Map<String, dynamic>>.from(body!);
        typeController.setListTypes(types);
        return ErrorModel(isError: false, code: 'Success', message: 'Types fetched successfully');
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final String errorMsg = errorBody['detail'] ?? 'Failed to fetch types';
        throw Exception(errorMsg);
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information', message: e.toString());
    }
  }

  /// Update
  Future<ErrorModel> updateType(String id, String typeCode, String typeName) async {
    try {
      TypeController typeController = Get.put(TypeController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }
      final res = await http.put(
        Uri.parse('$baseUrl/api/type/$id'),
        body: jsonEncode({
          'type_code': typeCode,
          'name': typeName,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      Map<String, dynamic>? types = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final updatedType = {
          'id': id,
          'typeCode': typeCode,
          'name': typeName,
        };

        typeController.updateType(updatedType);
        return ErrorModel(isError: false, code: 'Success', message: 'Type updated successfully');
      }else{
        throw Exception(types!['detail'] ?? 'Failed to update type');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information', message: e.toString());
    }
  }

  /// Delete
  Future<ErrorModel> deleteType(String id) async {
    try {
      TypeController typeController = Get.put(TypeController());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        return ErrorModel(isError: true, code: 'information', message: 'Token not found');
      }
      final res = await http.delete(
        Uri.parse('$baseUrl/api/type/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

      Map<String, dynamic>? types = jsonDecode(res.body);
      if (res.statusCode == 200) {
        typeController.removeType(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Type deleted successfully');
      }else{
        throw Exception(types!['detail'] ?? 'Failed to delete type');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'information', message: e.toString());
    }
  }
}
