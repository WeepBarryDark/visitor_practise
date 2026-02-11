import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskContractorSignInController extends ChangeNotifier{
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Client and site data for URL generation
  String? _clientSlug;
  String? get clientSlug => _clientSlug;

  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Contractor Sign In';
    return _currentSite!.displayName;
  }

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;

  /// Build contractor registration URL
  /// Format: https://app.worxsafety.com.au/{clientSlug}/projects/view/{siteId}
  String get contractorUrl {
    if (_clientSlug != null && _clientSlug!.isNotEmpty &&
        _currentSite != null && _currentSite!.id.isNotEmpty) {
      return 'https://app.worxsafety.com.au/$_clientSlug/projects/view/${_currentSite!.id}';
    }
    // Fallback to base URL if missing data
    return 'https://app.worxsafety.com.au';
  }

  /// Initialize with data from KioskDashboardController (more efficient - reuses loaded data)
  Future<void> initialiseWithKioskController(dynamic kioskController) async {
    try {
      // Reuse already-loaded assets from kioskController
      topLogo = kioskController.topLogo;
      bottomLogo = kioskController.bottomLogo;
      background = kioskController.background;
      _currentSite = kioskController.currentSite;

      // Load client slug for URL generation
      await _loadClientSlug();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _isCheckingInitial = false;
      notifyListeners();
    }
  }

  /// Load client slug from storage
  Future<void> _loadClientSlug() async {
    try {
      final clientJson = await SecureStorageService.getClinet();
      if (clientJson != null && clientJson.isNotEmpty) {
        final client = jsonDecode(clientJson) as Map<String, dynamic>;

        // Try to get slug from different possible fields
        _clientSlug = client['slug'] as String? ??
                      client['client_slug'] as String? ??
                      client['identifier'] as String?;

        debugPrint('ContractorSignIn: Extracted slug: $_clientSlug');

        if (_clientSlug == null || _clientSlug!.isEmpty) {
          debugPrint('⚠️ ContractorSignIn: Client slug is missing!');
        }
      } else {
        debugPrint('⚠️ ContractorSignIn: No client data found in storage');
      }
    } catch (e) {
      debugPrint('❌ ContractorSignIn: Error loading client slug: $e');
      _clientSlug = null;
    }
  }
}