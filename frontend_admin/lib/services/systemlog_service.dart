import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/systemlog_model.dart';
import '../shared/message_dialog.dart';

class SystemLogService {
  Future<List<SystemLogModel>> fetchSystemLogs(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('x-auth-token');

      if (accessToken == null || accessToken.isEmpty) {
        MessageDialog.showMessage('Error', 'No access token found', context);
        return [];
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/system-logs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((logJson) => SystemLogModel.fromJson(logJson)).toList();
      } else {
        MessageDialog.showMessage('Error', 'Failed to fetch system logs: ${response.statusCode}', context);
        return [];
      }
    } catch (e) {
      MessageDialog.showMessage('Error', e.toString(), context);
      return [];
    }
  }
}