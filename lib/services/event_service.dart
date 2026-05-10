import 'dart:convert';
import 'api_client.dart';

class EventService {
  static Future<List<dynamic>> getEvents() async {
    final response = await ApiClient.get('/events');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getEventById(String id) async {
    final response = await ApiClient.get('/events/$id');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/events', body: data);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/events/$id', body: data);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<bool> deleteEvent(String id) async {
    final response = await ApiClient.delete('/events/$id');
    return response.statusCode == 200;
  }
}
