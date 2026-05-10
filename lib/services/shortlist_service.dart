import 'dart:convert';
import 'api_client.dart';

class ShortlistService {
  static Future<Map<String, dynamic>> addToShortlist(String eventId, String vendorId) async {
    final response = await ApiClient.post('/shortlists', body: {'event_id': eventId, 'vendor_id': vendorId});
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<List<dynamic>> getEventShortlists(String eventId) async {
    final response = await ApiClient.get('/shortlists/$eventId');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> removeFromShortlist(String shortlistId) async {
    final response = await ApiClient.delete('/shortlists/$shortlistId');
    return response.statusCode == 200;
  }
}
