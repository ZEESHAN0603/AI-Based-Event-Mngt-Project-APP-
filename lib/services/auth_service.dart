import 'dart:convert';
import 'api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? city,
  }) async {
    final response = await ApiClient.post('/auth/register', auth: false, body: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone ?? '',
      'city': city ?? '',
    });
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.post('/auth/login', auth: false, formEncoded: true, body: {
      'username': email,
      'password': password,
    });
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['access_token'] != null) {
      await ApiClient.saveToken(data['access_token']);
    }
    return {'statusCode': response.statusCode, ...data};
  }

  static Future<Map<String, dynamic>?> getMe() async {
    final response = await ApiClient.get('/auth/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<void> logout() async {
    await ApiClient.clearToken();
  }
}
