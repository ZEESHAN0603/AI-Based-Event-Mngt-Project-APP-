import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      // Physical Android device on same Wi‑Fi network must use laptop IP.
      return 'http://192.168.1.6:8000';
    }
  }
}
