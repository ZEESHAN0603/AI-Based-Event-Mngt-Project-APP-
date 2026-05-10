import 'dart:convert';
import 'api_client.dart';

class BookingService {
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/bookings', body: data);
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }

  static Future<List<dynamic>> getOrganizerBookings() async {
    final response = await ApiClient.get('/bookings/me');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<List<dynamic>> getVendorBookings() async {
    final response = await ApiClient.get('/bookings/vendor');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<Map<String, dynamic>> updateBookingStatus(String id, String status) async {
    final response = await ApiClient.put('/bookings/$id/status', body: {'booking_status': status});
    return {'statusCode': response.statusCode, ...jsonDecode(response.body)};
  }
}
