import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_rental/models/property.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/property_controller.dart';
import '../models/error.dart';

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
}
