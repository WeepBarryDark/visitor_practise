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

  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }

}
