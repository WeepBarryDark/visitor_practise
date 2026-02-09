import 'dart:convert';

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
  static const String _keyTopLogo = 'top_logo';
    static const String _keyBottomLogo = 'bottom_logo';
  static const String _keyBackground = 'background';

  //Unexpected crash or exit - record last accessed location
  static const String _keyLastKioskAccess = 'last_last_kiosk_access';
  static const String _keyLastPrinter = 'last_printer';
  static const String _keyPrinterPaperType = 'last_printer_paper_typer';

  
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
      return await _storage.read(key: _keySites);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------  SelectedSite
  ///Save last SelectedSite page (string)
  static Future<void> saveSelectedSite(String selectedSite) async {
    try {
      await _storage.write(key: _keySelectedSite, value: selectedSite);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor SelectedSite data (JSON string)
  static Future<String?> getSelectedSite() async {
    try {
      return await _storage.read(key: _keySelectedSite);
    } catch (e) {
      debugPrint('Error reading sites: $e');
      return null;
    }
  }
  ///------------------------------------------ Last selected site 
  /// Save last printer page (string)-----------------------------
  static Future<void> saveLastPrinter({
    required String name,
    required String address,
    required String model,
  }) async {
    try {
      final printerData = jsonEncode({
        'name': name,
        'address': address,
        'model': model,
        'saved_at': DateTime.now().toIso8601String(),
      });
      await _storage.write(key: _keyLastPrinter, value: printerData);
    } catch (e) {
      debugPrint('Error saving printer info: $e');
    }
  }

  /// Get visitor sites data (JSON string)
 static Future<Map<String, dynamic>?> getLastPrinter() async {
    try {
      final printerJson = await _storage.read(key: _keyLastPrinter);
      if (printerJson == null || printerJson.isEmpty) {
        return null;
      }
      final printerData = jsonDecode(printerJson) as Map<String, dynamic>;
      return printerData;
    } catch (e) {
      debugPrint('Error reading printer info: $e');
      return null;
    }
  }
  /// Clear saved paper type
  static Future<void> clearLastPrinter() async {
    try {
      await _storage.delete(key: _keyLastPrinter);
    } catch (e) {
      debugPrint('Error clearing paper type: $e');
    }
  }
  /// Save last printer page (string)-----------------------------
  /// Save last printer paper type (string)-----------------------------
  static Future<void> savePaperType(Map<String, dynamic> paperTypeMap) async {
    try {
      final paperTypeJson = jsonEncode(paperTypeMap);
      await _storage.write(
        key: _keyPrinterPaperType,
        value: paperTypeJson,
      );
      debugPrint('Paper type saved: ${paperTypeMap['code']}');
    } catch (e) {
      debugPrint('Error saving paper type: $e');
    }
  }

  /// Get saved paper type (returns Map)
  static Future<Map<String, dynamic>?> getPaperType() async {
    try {
      final paperTypeJson = await _storage.read(key: _keyPrinterPaperType);
      if (paperTypeJson != null && paperTypeJson.isNotEmpty) {
        return jsonDecode(paperTypeJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error reading paper type: $e');
      return null;
    }
  }

  /// Clear saved paper type
  static Future<void> clearPaperType() async {
    try {
      await _storage.delete(key: _keyPrinterPaperType);
    } catch (e) {
      debugPrint('Error clearing paper type: $e');
    }
  }
    /// Save last printer paper type (string)-----------------------------
  ///------------------------------------------ Last access 
  /// Save last accessed page (string)
    static Future<void> saveLastKioskAccess(String locationString) async {
    try {
      await _storage.write(key: _keyLastKioskAccess, value: locationString);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  /// Get visitor sites data (JSON string)
  static Future<String?> getLastKioskAccess() async {
    try {
      return await _storage.read(key: _keyLastKioskAccess);
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
  ///------------------------------------------ client top logo bytes
  /// Save client logo bytes (from client API response)
  static Future<void> saveClientTopLogoBytes(Uint8List logoBytes) async {
    try {
      final b64 = base64Encode(logoBytes);
      await _storage.write(key: _keyTopLogo, value: b64);
      debugPrint('Client logo bytes saved successfully');
    } catch (e) {
      debugPrint('Error saving client logo bytes: $e');
    }
  }

  /// Get client logo bytes (returns Uint8List)
  static Future<Uint8List?> getClientTopLogoBytes() async {
    try {
      final b64String = await _storage.read(key: _keyTopLogo);
      if (b64String == null || b64String.isEmpty) {
        return null;
      }
      return base64Decode(b64String);
    } catch (e) {
      debugPrint('Error reading client logo bytes: $e');
      return null;
    }
  }
  ///------------------------------------------ client top logo bytes
    ///------------------------------------------ client bottom logo bytes
  /// Save client bottom logo bytes (from client API response)
  static Future<void> saveClientBottomLogoBytes(Uint8List logoBytes) async {
    try {
      final b64 = base64Encode(logoBytes);
      await _storage.write(key: _keyBottomLogo, value: b64);
      debugPrint('Client logo bytes saved successfully');
    } catch (e) {
      debugPrint('Error saving client logo bytes: $e');
    }
  }

  /// Get client bottom logo bytes (returns Uint8List)
  static Future<Uint8List?> getClientBottomLogoBytes() async {
    try {
      final b64String = await _storage.read(key: _keyBottomLogo);
      if (b64String == null || b64String.isEmpty) {
        return null;
      }
      return base64Decode(b64String);
    } catch (e) {
      debugPrint('Error reading client logo bytes: $e');
      return null;
    }
  }
  ///------------------------------------------ client logo bytes

  ///------------------------------------------ client background bytes
  /// Save client background bytes (from client API response)
  static Future<void> saveClientBackgroundBytes(Uint8List backgroundBytes) async {
    try {
      final b64 = base64Encode(backgroundBytes);
      await _storage.write(key: _keyBackground, value: b64);
      debugPrint('Client background bytes saved successfully');
    } catch (e) {
      debugPrint('Error saving client background bytes: $e');
    }
  }

  /// Get client background bytes (returns Uint8List)
  static Future<Uint8List?> getClientBackgroundBytes() async {
    try {
      final b64String = await _storage.read(key: _keyBackground);
      if (b64String == null || b64String.isEmpty) {
        return null;
      }
      return base64Decode(b64String);
    } catch (e) {
      debugPrint('Error reading client background bytes: $e');
      return null;
    }
  }
  ///------------------------------------------ client background bytes

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }

}
