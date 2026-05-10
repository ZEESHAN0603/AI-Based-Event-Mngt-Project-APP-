import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

enum UserRole { organizer, vendor, admin }

class UserProvider with ChangeNotifier {
  UserRole? _selectedRole;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  UserRole? get selectedRole => _selectedRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  String get userName => _userData?['name'] ?? 'User';
  String get userEmail => _userData?['email'] ?? '';
  String get userId => _userData?['id'] ?? '';

  void setRole(UserRole role) {
    _selectedRole = role;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      if (result['statusCode'] == 200 && result['access_token'] != null) {
        // Fetch user data
        final me = await AuthService.getMe();
        if (me != null) {
          _userData = me;
          _selectedRole = _roleFromString(me['role']);
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _error = result['detail'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        name: name, email: email, password: password,
        role: role, phone: phone, city: city,
      );
      _isLoading = false;
      if (result['message'] != null && result['message'].toString().contains('successfully')) {
        notifyListeners();
        return true;
      }
      _error = result['detail'] ?? 'Registration failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Try to restore session from saved token
  Future<bool> tryAutoLogin() async {
    final token = await ApiClient.getToken();
    if (token == null) return false;

    try {
      final me = await AuthService.getMe();
      if (me != null) {
        _userData = me;
        _selectedRole = _roleFromString(me['role']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  void logout() {
    AuthService.logout();
    _isAuthenticated = false;
    _selectedRole = null;
    _userData = null;
    _error = null;
    notifyListeners();
  }

  UserRole? _roleFromString(String? role) {
    switch (role) {
      case 'organizer': return UserRole.organizer;
      case 'vendor': return UserRole.vendor;
      case 'admin': return UserRole.admin;
      default: return null;
    }
  }
}
