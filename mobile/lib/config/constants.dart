class AppConstants {
  // API Configuration
  // Use Android emulator host alias by default for emulator compatibility.
  // Override at build/run-time by passing --dart-define=API_BASE_URL="http://your:host:3000/api"
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    // Android emulator (default), iOS simulator and web/desktop can use localhost
    return 'http://10.0.2.2:3000/api';
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
