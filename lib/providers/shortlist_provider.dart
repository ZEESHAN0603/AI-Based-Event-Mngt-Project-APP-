import 'package:flutter/material.dart';
import '../services/shortlist_service.dart';
import '../models/vendor.dart';

class ShortlistProvider with ChangeNotifier {
  List<Map<String, dynamic>> _shortlistedItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get shortlistedItems => _shortlistedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShortlist(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shortlistedItems = await ShortlistService.getEventShortlists(eventId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load shortlist';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToShortlist(String eventId, String vendorId) async {
    try {
      final result = await ShortlistService.addToShortlist(eventId, vendorId);
      if (result['statusCode'] == 201 || result['statusCode'] == 200) {
        await fetchShortlist(eventId);
        return true;
      }
      _error = result['detail'] ?? 'Failed to add to shortlist';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromShortlist(String eventId, String shortlistId) async {
    try {
      final success = await ShortlistService.removeFromShortlist(shortlistId);
      if (success) {
        await fetchShortlist(eventId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isShortlisted(String vendorId) {
    return _shortlistedItems.any((item) => item['vendor_id'] == vendorId);
  }
  
  String? getShortlistId(String vendorId) {
    try {
      final item = _shortlistedItems.firstWhere((item) => item['vendor_id'] == vendorId);
      return item['id'];
    } catch (e) {
      return null;
    }
  }
}
