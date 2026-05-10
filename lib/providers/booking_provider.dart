import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _organizerBookings = [];
  List<Booking> _vendorBookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get organizerBookings => _organizerBookings;
  List<Booking> get vendorBookings => _vendorBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrganizerBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await BookingService.getOrganizerBookings();
      _organizerBookings = data.map((json) => Booking.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await BookingService.getVendorBookings();
      _vendorBookings = data.map((json) => Booking.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking(Map<String, dynamic> data) async {
    try {
      final result = await BookingService.createBooking(data);
      if (result['statusCode'] == 201) {
        await fetchOrganizerBookings();
        return true;
      }
      _error = result['detail'] ?? 'Failed to create booking';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(String id, String status) async {
    try {
      final result = await BookingService.updateBookingStatus(id, status);
      if (result['statusCode'] == 200) {
        await fetchVendorBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
