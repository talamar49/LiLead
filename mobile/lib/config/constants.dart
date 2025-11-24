import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  // Use Android emulator host alias by default for emulator compatibility.
  // Override at build/run-time by passing --dart-define=API_BASE_URL="http://your:host:3000/api"
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // -----------------------------------------------------------------------
    // ANDROID CONFIGURATION:
    // -----------------------------------------------------------------------
    // The start-all.sh script automatically sets up adb reverse for physical devices,
    // so localhost will work on physical devices.
    // For emulators, use 10.0.2.2 (special alias for host machine)
    // -----------------------------------------------------------------------
    
    // Try to detect if running on emulator vs physical device
    // This is a simple heuristic - emulators typically have "goldfish" or "ranchu" in model
    // For now, we'll default to localhost since start-all.sh sets up adb reverse
    return 'http://localhost:3000/api';
    
    // If the above doesn't work and you're using an emulator without adb reverse:
    // return 'http://10.0.2.2:3000/api';
    
    // If you're on WiFi (no USB) with a physical device, use your PC's IP:
    // return 'http://YOUR_PC_IP:3000/api';
  }
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  
  // App Info
  static const String appName = 'LiLead';
  static const String appNameHebrew = 'לי-ליד';
  
  // Pagination
  static const int pageSize = 20;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
