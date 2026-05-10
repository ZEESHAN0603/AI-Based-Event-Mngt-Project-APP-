import 'dart:convert';
import 'api_client.dart';

class AvailabilityService {
  static Future<Map<String, dynamic>> blockDate(String date) async {
    final response = await ApiClient.post('/availability/block', body: {'blocked_date': date});
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<bool> removeBlockedDate(String id) async {
    final response = await ApiClient.delete('/availability/$id');
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getMyAvailability() async {
    final response = await ApiClient.get('/availability/me');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }
}
