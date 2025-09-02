import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/models/property_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/property_controller.dart';
import '../models/error.dart';
import '../models/propertyunit_model.dart';

class PropertyService {
  final String baseUrl = dotenv.env['API_URL']!;

  /// CREATE Property
  Future<ErrorModel> createProperty(PropertyModel propertyData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/create-property'),
        body: jsonEncode({
          'name': propertyData.name,
          'address': propertyData.address,
          'city': propertyData.city,
          'district': propertyData.district,
          'province': propertyData.province,
          'postal_code': propertyData.postalCode,
          'latitude': propertyData.latitude,
          'longitude': propertyData.longitude,
          'description': propertyData.description,
          'type_id': propertyData.typeId,
          'owner_id': propertyData.ownerId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.find<PropertyController>().addProperty(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Property created successfully');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create property');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// READ all properties
  Future<ErrorModel> getAllProperties() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/getallproperty'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<Map<String, dynamic>> properties = List<Map<String, dynamic>>.from(jsonList);
        Get.find<PropertyController>().setListProperties(properties);
        return ErrorModel(isError: false, code: 'Success', message: 'Properties fetched');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch properties');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// UPDATE Property
  Future<ErrorModel> updateProperty(String id, PropertyModel propertyData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/property/$id'),
        body: jsonEncode(propertyData),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.find<PropertyController>().updateProperty(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Property updated');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to update property');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// DELETE Property
  Future<ErrorModel> deleteProperty(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/property/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.find<PropertyController>().removeProperty(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Property deleted');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to delete property');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// READ all types
  Future<ErrorModel> getAllTypes() async {
    try {
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
        final PropertyController typeController = Get.find<PropertyController>();
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

  /// CREATE unit
  Future<ErrorModel> createPropertyUnit(PropertyUnitModel unitData) async {
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
        Uri.parse('$baseUrl/api/create-unit'),
        body: jsonEncode(unitData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.find<PropertyController>().addUnit(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Unit created successfully');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to create unit');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// READ all units
  Future<ErrorModel> getAllUnits() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-all-units'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        List<Map<String, dynamic>> units = List<Map<String, dynamic>>.from(jsonList);
        Get.find<PropertyController>().setUnits(units);
        return ErrorModel(isError: false, code: 'Success', message: 'Units fetched');
      } else {
        throw Exception('Failed to fetch units');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// UPDATE unit
  Future<ErrorModel> updatePropertyUnit(String id, PropertyUnitModel unitData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/update-unit/$id'),
        body: jsonEncode(unitData.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.find<PropertyController>().updateUnit(jsonResponse);
        return ErrorModel(isError: false, code: 'Success', message: 'Unit updated');
      } else {
        throw Exception(jsonResponse['detail'] ?? 'Failed to update unit');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }

  /// DELETE unit
  Future<ErrorModel> deletePropertyUnit(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        return ErrorModel(isError: true, code: 'unauthorized', message: 'Access token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/delete-unit/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.find<PropertyController>().removeUnit(id);
        return ErrorModel(isError: false, code: 'Success', message: 'Unit deleted');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['detail'] ?? 'Failed to delete unit');
      }
    } catch (e) {
      return ErrorModel(isError: true, code: 'exception', message: e.toString());
    }
  }
}
