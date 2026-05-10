import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../services/availability_service.dart';

class AvailabilityProvider with ChangeNotifier {
  List<BlockedDate> _blockedDates = [];
  bool _isLoading = false;
  String? _error;

  List<BlockedDate> get blockedDates => _blockedDates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyAvailability() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AvailabilityService.getMyAvailability();
      _blockedDates = data.map((json) => BlockedDate.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load availability';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> blockDate(String date) async {
    try {
      final result = await AvailabilityService.blockDate(date);
      if (result['statusCode'] == 201) {
        await fetchMyAvailability();
        return true;
      }
      _error = result['detail'] ?? 'Failed to block date';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeBlockedDate(String id) async {
    try {
      final success = await AvailabilityService.removeBlockedDate(id);
      if (success) {
        await fetchMyAvailability();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
