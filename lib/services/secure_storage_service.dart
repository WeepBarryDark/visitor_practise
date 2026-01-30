import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Secure Storage Service for sensitive data like auth tokens
/// Provides encrypted storage for authentication, user data, app settings, and visitor management
class SecureStorageService {
  // ============================================================================
  // CONFIGURATION & STORAGE INSTANCE
  // ============================================================================

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    webOptions: WebOptions(
      dbName: 'WorxCompanionDB',
      publicKey: 'WorxCompanionPublicKey',
    ),
  );

  // ============================================================================
  // STORAGE KEYS
  // ============================================================================

  // Authentication keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keySites = 'visitor_sites';
  static const String _keyClient = 'visitor_client';
  static const String _keySelectedSite = 'selected_site';
  static const String _keyAdminPin = 'admin_pin';
  static const String _keyAdminDashboardSettings = 'admin_dashboard_settings';

  //logo background image
  static const String _keyLogo = 'custom_logo';
  static const String _keyBackgroundImage = 'custom_background_image';

  //Unexpected crash or exit - record last accessed location
  static const String _keyLastAccess = 'last_access';

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      debugPrint('Auth token saved securely');
    } catch (e) {
      debugPrint('Error saving auth token: $e');
      rethrow;
    }
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }
  
  /* exmaple, don't really need
  /// Delete authentication token
  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      debugPrint('Auth token deleted successfully');
    } catch (e) {
      debugPrint('Error deleting auth token: $e');
      rethrow;
    }
  }
  */
  ///------------------------------------------ Auth Token 
  /// Save visitor sites data (JSON string)
  static Future<void> saveSites(String sitesJson) async {
    try {
      await _storage.write(key: _keySites, value: sitesJson);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getSites() async {
    try {
      return await _storage.read(key: _keyLastAccess);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ Site Token 
  /// Save visitor sites data (JSON string)
  static Future<void> saveClient(String clinetJson) async {
    try {
      await _storage.write(key: _keyClient, value: clinetJson);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getClinet() async {
    try {
      return await _storage.read(key: _keyClient);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ Site Token 
  /// Save last accessed page (string)
    static Future<void> saveLastAccess(String locationString) async {
    try {
      await _storage.write(key: _keyLastAccess, value: locationString);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getLastAccess() async {
    try {
      return await _storage.read(key: _keyLastAccess);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ last accessed page Token 
    /// Save last accessed page (string)
    static Future<void> saveLogo(String logoString) async {
    try {
      await _storage.write(key: _keyLogo, value: logoString);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getLogo () async {
    try {
      return await _storage.read(key: _keyLogo);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ last accessed page Token
  ///Save last accessed page (string)
  static Future<void> saveSelectedSite(String selectedSite) async {
    try {
      await _storage.write(key: _keySelectedSite, value: selectedSite);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getSelectedSite() async {
    try {
      return await _storage.read(key: _keySelectedSite);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ last accessed page Token 
  /// Save last accessed page (string)
  static Future<void> saveBackgroundImage(String backgroundImage) async {
    try {
      await _storage.write(key: _keyBackgroundImage, value: backgroundImage);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getBackgroundImage() async {
    try {
      return await _storage.read(key: _keyBackgroundImage);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ last accessed page Token 
  /// Save admin pin page (string)
  static Future<void> saveAdminPin(String adminPin) async {
    try {
      await _storage.write(key: _keyAdminPin, value: adminPin);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getAdminPin() async {
    try {
      return await _storage.read(key: _keyAdminPin);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ admin pin
  /// Save admin pin page (string)
  static Future<void> saveAdminDashboardSettings(String adminDashboardSettings) async {
    try {
      await _storage.write(key: _keyAdminDashboardSettings, value: adminDashboardSettings);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getAdminDashboardSettings () async {
    try {
      return await _storage.read(key: _keyAdminDashboardSettings);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ admin pin
  ///

  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }

}
