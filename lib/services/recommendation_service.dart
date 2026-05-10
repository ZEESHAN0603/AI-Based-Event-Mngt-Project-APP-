import 'dart:convert';
import 'api_client.dart';

class RecommendationService {
  static Future<Map<String, dynamic>> getRecommendations(String eventId, {String? categoryId}) async {
    final body = <String, dynamic>{'event_id': eventId};
    if (categoryId != null) body['category_id'] = categoryId;
    final response = await ApiClient.post('/ai/recommend', body: body);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }
}
