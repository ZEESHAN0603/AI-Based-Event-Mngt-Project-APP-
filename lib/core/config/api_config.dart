
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'http://localhost:8000';
    }
    return 'https://synora-backend-rhi7.onrender.com';
  }
}
