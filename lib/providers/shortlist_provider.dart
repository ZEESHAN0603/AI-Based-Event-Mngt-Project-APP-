import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/shortlist_service.dart';
import 'dart:convert';
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
      final data = await ShortlistService.getEventShortlists(eventId);
      // Enrich each shortlist item with full vendor details
      final enriched = await Future.wait(data.map((item) async {
        final vendorId = item['vendor_id'];
        try {
          final response = await ApiClient.get('/vendors/$vendorId');
          final vendorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
          final enrichedItem = Map<String, dynamic>.from(item);
          enrichedItem['vendor'] = vendorData;
          return enrichedItem;
        } catch (e) {
          // If fetching vendor fails, keep original item
          return item;
        }
      }));
      _shortlistedItems = enriched.cast<Map<String, dynamic>>();
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
