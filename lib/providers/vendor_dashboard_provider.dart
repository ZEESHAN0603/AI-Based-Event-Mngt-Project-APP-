import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class VendorDashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience Getters
  Map<String, dynamic> get stats => _dashboardData?['stats'] ?? {};
  List<dynamic> get bookingRequests => _dashboardData?['booking_requests'] ?? [];
  List<dynamic> get schedule => _dashboardData?['schedule'] ?? [];
  List<dynamic> get reviews => _dashboardData?['reviews'] ?? [];
  Map<String, dynamic> get performance => _dashboardData?['performance'] ?? {};
  Map<String, dynamic> get revenueAnalytics => _dashboardData?['revenue_analytics'] ?? {};
  String get availabilityStatus => _dashboardData?['availability_status'] ?? 'Available';
  List<dynamic> get activities => _dashboardData?['activities'] ?? [];

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/vendors/me/dashboard');
      if (response.statusCode == 200) {
        _dashboardData = jsonDecode(response.body);
        _error = null;
      } else {
        final errorBody = jsonDecode(response.body);
        _error = errorBody['detail'] ?? 'Failed to load dashboard data';
      }
    } catch (e) {
      _error = 'Failed to connect to server';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRequestStatus(String bookingId, String status) async {
    try {
      final response = await ApiClient.put(
        '/bookings/$bookingId/status',
        body: {'booking_status': status},
      );
      if (response.statusCode == 200) {
        // Refresh dashboard data to reflect state change
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
