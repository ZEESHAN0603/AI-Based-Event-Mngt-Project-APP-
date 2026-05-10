import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/vendor_service.dart';

class VendorProvider with ChangeNotifier {
  List<Vendor> _vendors = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Vendor> get vendors => _vendors;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Vendor> get pendingVendors => _vendors.where((v) => !v.approved).toList();

  Future<void> fetchVendors({String? categoryId, String? search, String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await VendorService.getVendors(
        categoryId: categoryId,
        search: search,
        location: location,
      );
      _vendors = data.map((json) => Vendor.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load vendors';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await VendorService.getCategories();
      _categories = data.cast<Map<String, dynamic>>();
    } catch (e) {
      _categories = [];
    }
    notifyListeners();
  }

  void toggleShortlist(String vendorId) {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].isShortlisted = !_vendors[index].isShortlisted;
      notifyListeners();
    }
  }

  void bookVendor(String vendorId) {
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index != -1) {
      _vendors[index].isBooked = true;
      notifyListeners();
    }
  }

  Future<void> updateVendorStatus(String vendorId, VendorStatus status) async {
    final bool approved = status == VendorStatus.approved;
    final success = await VendorService.updateVendorStatus(vendorId, approved);
    if (success) {
      await fetchVendors(); // Refresh list
    }
  }
}
