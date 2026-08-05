import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }
    // Si es un emulador de Android, localhost es la IP 10.0.2.2
    return Platform.isAndroid 
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }
}