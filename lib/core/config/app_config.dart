import 'package:flutter/foundation.dart';

/// White-label app configuration
/// Each brand has a unique app_id (e.g., "shine_wash", "quick_clean")
/// Firebase structure: /apps/{app_id}/
class AppConfig {
  static const String _defaultAppId = 'shine_wash';
  
  // This would be set at build time or fetched from Remote Config
  static String _appId = _defaultAppId;
  
  /// Get current app ID (brand ID)
  static String get appId => _appId;
  
  /// Set app ID (usually done at app initialization)
  static void setAppId(String id) {
    _appId = id;
    if (kDebugMode) {
      print('AppConfig: App ID set to $_appId');
    }
  }
  
  /// App branding info (loaded from Firestore /apps/{appId}/config)
  static String get appName => 'Shine Wash'; // Can be loaded from config
  static String get primaryColor => '#2196F3'; // Can be loaded from config
  
  /// Check if using default app
  static bool get isDefaultApp => _appId == _defaultAppId;
  
  /// Reset to default (useful for testing)
  static void reset() {
    _appId = _defaultAppId;
  }
  
  /// Firebase collection path helper
  static String get basePath => 'apps/$_appId';
  static String collectionPath(String collection) => '$basePath/$collection';
}
