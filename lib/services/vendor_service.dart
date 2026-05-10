import 'dart:convert';
import 'api_client.dart';

class VendorService {
  static Future<List<dynamic>> getVendors({
    String? categoryId,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    final params = <String, String>{};
    if (categoryId != null) params['category_id'] = categoryId;
    if (location != null) params['location'] = location;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (search != null) params['search'] = search;
    final query = Uri(queryParameters: params.isNotEmpty ? params : null).query;
    final path = query.isNotEmpty ? '/vendors?$query' : '/vendors';
    final response = await ApiClient.get(path);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>?> getVendorById(String id) async {
    final response = await ApiClient.get('/vendors/$id');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await ApiClient.get('/categories');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>> createVendorProfile(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/vendors/profile', body: data);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> updateVendorProfile(Map<String, dynamic> data) async {
    final response = await ApiClient.put('/vendors/profile', body: data);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<bool> updateVendorStatus(String vendorId, bool approved) async {
    final response = await ApiClient.patch('/vendors/$vendorId/approve?approve=$approved', body: {});
    return response.statusCode == 200;
  }
}
