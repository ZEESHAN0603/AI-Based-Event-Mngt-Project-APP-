import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // IMPORTANT: Change this to your PC's local IP for physical device testing.
  // Use 'http://10.0.2.2:8000' for Android emulator.
  // Use 'http://127.0.0.1:8000' for web/desktop.
  static const String baseUrl = 'http://10.129.158.174:8000';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> get(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.get(Uri.parse('$baseUrl$path'), headers: headers).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body, bool auth = true, bool formEncoded = false}) async {
    if (formEncoded) {
      // For OAuth2 login form
      final token = await getToken();
      final headers = <String, String>{'Content-Type': 'application/x-www-form-urlencoded'};
      if (auth && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body?.map((k, v) => MapEntry(k, v.toString()))).timeout(const Duration(seconds: 10));
    }
    final headers = await _headers(auth: auth);
    return http.post(Uri.parse('$baseUrl$path'), headers: headers, body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.put(Uri.parse('$baseUrl$path'), headers: headers, body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> delete(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> patch(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.patch(Uri.parse('$baseUrl$path'), headers: headers, body: body != null ? jsonEncode(body) : null).timeout(const Duration(seconds: 10));
  }
}
