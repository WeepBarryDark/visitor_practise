import 'dart:typed_data';
import 'dart:convert';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

/// Shared initialization helper to reduce code duplication across controllers
class InitializationHelper {
  InitializationHelper._();

  /// Load client branding assets (logos and background)
  static Future<BrandingAssets> loadBrandingAssets({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final topLogo = await SecureStorageService.getClientTopLogoBytes().timeout(timeout);
      final bottomLogo = await SecureStorageService.getClientBottomLogoBytes().timeout(timeout);
      final background = await SecureStorageService.getClientBackgroundBytes().timeout(timeout);

      return BrandingAssets(
        topLogo: topLogo,
        bottomLogo: bottomLogo,
        background: background,
      );
    } catch (e) {
      // Return empty assets on error - controllers can handle gracefully
      return BrandingAssets(
        topLogo: null,
        bottomLogo: null,
        background: null,
      );
    }
  }

  /// Load selected site from storage
  static Future<SiteItem?> loadSelectedSite({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final savedSelectedSite = await SecureStorageService.getSelectedSite().timeout(timeout);
      if (savedSelectedSite == null || savedSelectedSite.isEmpty) {
        return null;
      }

      final currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
      return SiteItem.fromJson(currentSiteMap);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated with valid token and client
  static Future<AuthStatus> checkAuthentication({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final token = await SecureStorageService.getAuthToken().timeout(timeout);
      final client = await SecureStorageService.getClinet().timeout(timeout);

      if (token == null || token.isEmpty) {
        return AuthStatus.missingToken;
      }

      if (client == null || client.isEmpty) {
        return AuthStatus.missingClient;
      }

      return AuthStatus.authenticated;
    } catch (e) {
      return AuthStatus.error;
    }
  }

  /// Load kiosk configuration from admin dashboard settings
  static Future<KioskConfig?> loadKioskConfig({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final kioskOptions = await SecureStorageService.getAdminDashboardSettings().timeout(timeout);
      if (kioskOptions == null || kioskOptions.isEmpty) {
        return null;
      }

      final kioskOptionsData = jsonDecode(kioskOptions) as Map<String, dynamic>;
      return KioskConfig.fromJson(kioskOptionsData);
    } catch (e) {
      return null;
    }
  }
}

/// Branding assets (logos and background)
class BrandingAssets {
  final Uint8List? topLogo;
  final Uint8List? bottomLogo;
  final Uint8List? background;

  BrandingAssets({
    this.topLogo,
    this.bottomLogo,
    this.background,
  });

  bool get hasAssets => topLogo != null || bottomLogo != null || background != null;
}

/// Authentication status
enum AuthStatus {
  authenticated,
  missingToken,
  missingClient,
  error,
}

/// Kiosk configuration
class KioskConfig {
  final bool enableVisitorSignIn;
  final bool enableVisitorSignOut;
  final bool enableVisitorDelivery;
  final bool enableContractorSignIn;
  final bool enableContractorSignOut;
  final bool enableVisitorRetrieveBadge;
  final bool reqPrint;

  // Field configurations
  final bool reqPhone;
  final bool reqCompany;
  final bool reqAddress;
  final bool reqWorkType;
  final bool reqSupervisor;
  final bool reqVisitorPhoto;
  final bool showPhone;
  final bool showCompany;
  final bool showAddress;
  final bool showWorkType;

  // Notification configurations
  final bool sendSms;
  final bool sendEmail;

  KioskConfig({
    this.enableVisitorSignIn = true,
    this.enableVisitorSignOut = true,
    this.enableVisitorDelivery = false,
    this.enableContractorSignIn = false,
    this.enableContractorSignOut = false,
    this.enableVisitorRetrieveBadge = false,
    this.reqPrint = false,
    this.reqPhone = true,
    this.reqCompany = true,
    this.reqAddress = true,
    this.reqWorkType = true,
    this.reqSupervisor = true,
    this.reqVisitorPhoto = false,
    this.showPhone = true,
    this.showCompany = true,
    this.showAddress = true,
    this.showWorkType = true,
    this.sendSms = true,
    this.sendEmail = true,
  });

  factory KioskConfig.fromJson(Map<String, dynamic> json) {
    return KioskConfig(
      enableVisitorSignIn: json['enable_visitor_sign_in'] ?? true,
      enableVisitorSignOut: json['enable_visitor_sign_out'] ?? true,
      enableVisitorDelivery: json['enable_visitor_delivery'] ?? false,
      enableContractorSignIn: json['enable_contractor_sign_in'] ?? false,
      enableContractorSignOut: json['enable_contractor_sign_out'] ?? false,
      enableVisitorRetrieveBadge: json['enable_visitor_retrieve_badge'] ?? false,
      reqPrint: json['req_print'] ?? false,
      reqPhone: json['req_phone'] ?? true,
      reqCompany: json['req_company'] ?? true,
      reqAddress: json['req_address'] ?? true,
      reqWorkType: json['req_work_type'] ?? true,
      reqSupervisor: json['req_supervisor'] ?? true,
      reqVisitorPhoto: json['req_visitor_photo'] ?? false,
      showPhone: json['show_phone'] ?? true,
      showCompany: json['show_company'] ?? true,
      showAddress: json['show_address'] ?? true,
      showWorkType: json['show_work_type'] ?? true,
      sendSms: json['send_sms'] ?? true,
      sendEmail: json['send_email'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_visitor_sign_in': enableVisitorSignIn,
      'enable_visitor_sign_out': enableVisitorSignOut,
      'enable_visitor_delivery': enableVisitorDelivery,
      'enable_contractor_sign_in': enableContractorSignIn,
      'enable_contractor_sign_out': enableContractorSignOut,
      'enable_visitor_retrieve_badge': enableVisitorRetrieveBadge,
      'req_print': reqPrint,
      'req_phone': reqPhone,
      'req_company': reqCompany,
      'req_address': reqAddress,
      'req_work_type': reqWorkType,
      'req_supervisor': reqSupervisor,
      'req_visitor_photo': reqVisitorPhoto,
      'show_phone': showPhone,
      'show_company': showCompany,
      'show_address': showAddress,
      'show_work_type': showWorkType,
      'send_sms': sendSms,
      'send_email': sendEmail,
    };
  }
}
