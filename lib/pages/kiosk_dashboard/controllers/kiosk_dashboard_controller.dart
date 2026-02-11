import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskDashboardController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;
  //------------------------------------
  late final SiteItem currentSite;
  //---------------------------------------------------- setting
  // Screen size setting
  String _screenSize = 'medium';
  String get screenSize => _screenSize;

  // Printer settings
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Field configurations
  bool _reqFullName = true;
  bool get reqFullName => _reqFullName;

  bool _reqEmail = true;
  bool get reqEmail => _reqEmail;

  bool _reqPhone = false;
  bool get reqPhone => _reqPhone;

  bool _reqWorkType = false;
  bool get reqWorkType => _reqWorkType;

  bool _reqCompany = false;
  bool get reqCompany => _reqCompany;

  bool _reqAddress = false;
  bool get reqAddress => _reqAddress;

  bool _reqPersonVisiting = false;
  bool get reqPersonVisiting => _reqPersonVisiting;

  bool _reqSignInTime = false;
  bool get reqSignInTime => _reqSignInTime;

  bool _reqVisitorPhoto = false;
  bool get reqVisitorPhoto => _reqVisitorPhoto;

  // Notification configurations
  bool _notifyDeliverySms = false;
  bool get notifyDeliverySms => _notifyDeliverySms;

  bool _notifyDeliveryEmail = false;
  bool get notifyDeliveryEmail => _notifyDeliveryEmail;

  bool _notifyPersonVisitingSms = false;
  bool get notifyPersonVisitingSms => _notifyPersonVisitingSms;

  bool _notifyPersonVisitingEmail = false;
  bool get notifyPersonVisitingEmail => _notifyPersonVisitingEmail;

  //Enable Functionalities
  bool _enableVisitorSignIn = true;
  bool get enableVisitorSignIn => _enableVisitorSignIn;

  bool _enableVisitorSignOut = true;
  bool get enableVisitorSignOut => _enableVisitorSignOut;

  bool _enableVisitorDelivery = false;
  bool get enableVisitorDelivery => _enableVisitorDelivery;

  bool _enableContractorSignIn = false;
  bool get enableContractorSignIn => _enableContractorSignIn;

  bool _enableVisitorRetrieveBadge = false;
  bool get enableVisitorRetrieveBadge => _enableVisitorRetrieveBadge;

  bool _enableContractorSignOut = false;
  bool get enableContractorSignOut => _enableContractorSignOut;
  //-------------------------------------------- all setting above


  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  // Persistent error message (stays visible at top of screen)
  String? _persistentErrorMessage;
  String? get persistentErrorMessage => _persistentErrorMessage;

  /// Set persistent error message (shown at top of dashboard)
  void setPersistentError(String message) {
    _persistentErrorMessage = message;
    notifyListeners();
  }

  /// Clear persistent error message
  void clearPersistentError() {
    _persistentErrorMessage = null;
    notifyListeners();
  }

  Future<void> initializing({
    required Future<void> Function(String nextRoute) onFailInitialization,
    BuildContext? context,
  }) async {
    try {
      // Load logos and background - default value, cannot be null
      topLogo = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));
      bottomLogo = await SecureStorageService.getClientBottomLogoBytes().timeout(const Duration(seconds: 5));
      background = await SecureStorageService.getClientBackgroundBytes().timeout(const Duration(seconds: 5));

      //retrival from local storage for initialization
      //test Token--------------------- go to auth page re-sign
      final savedToken = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      final saveSelectedClient = await SecureStorageService.getClinet().timeout(const Duration(seconds: 5));
      if (savedToken == null || savedToken.isEmpty || saveSelectedClient == null || saveSelectedClient.isEmpty) {
        // Show error BEFORE navigation
        if (context != null && context.mounted) {
          context.showError('Token or client issue, please sign in again');
          await Future.delayed(const Duration(milliseconds: 800));
        }
        await SecureStorageService.clearAll();
        await onFailInitialization(AppRoutes.auth);
        return;
      }

      //test select site--------------------- serious error, logout
      final savedSelectedSite = await SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite == null || savedSelectedSite.isEmpty) {
        // SERIOUS ERROR: Clear all data and logout
        if (context != null && context.mounted) {
          context.showError('Selected site issue, logging out');
          await Future.delayed(const Duration(milliseconds: 800));
        }
        await SecureStorageService.clearAll();
        await onFailInitialization(AppRoutes.auth);
        return;
      }
      final currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
      currentSite = SiteItem.fromJson(currentSiteMap);

      final kioskOptions = await SecureStorageService.getAdminDashboardSettings().timeout(const Duration(seconds: 5));
      //final selectedAdminPin = await SecureStorageService.getAdminPin().timeout(const Duration(seconds: 5));

      final Map<String, dynamic> kioskOptionsData;
      if (kioskOptions != null && kioskOptions.isNotEmpty) {
        kioskOptionsData = jsonDecode(kioskOptions) as Map<String, dynamic>;
        //size and printer
        _screenSize = kioskOptionsData['screen_size'] ?? 'medium';
        _reqPrint = kioskOptionsData['req_print'] ?? false;
         // Load field configurations
        _reqFullName = kioskOptionsData['req_full_name'] ?? true;
        _reqEmail = kioskOptionsData['req_email'] ?? true;
        _reqPhone = kioskOptionsData['req_phone'] ?? true;
        _reqWorkType = kioskOptionsData['req_work_type'] ?? true;
        _reqCompany = kioskOptionsData['req_company'] ?? true;
        _reqAddress = kioskOptionsData['req_address'] ?? true;
        _reqPersonVisiting = kioskOptionsData['req_person_visiting'] ?? true;
        _reqSignInTime = kioskOptionsData['req_sign_in_time'] ?? false;
        _reqVisitorPhoto = kioskOptionsData['req_visitor_photo'] ?? false;
        // Load notification configurations
        _notifyDeliverySms = kioskOptionsData['notify_delievery_sms'] ?? true;
        _notifyDeliveryEmail = kioskOptionsData['notify_delievery_email'] ?? true;
        _notifyPersonVisitingSms = kioskOptionsData['notify_person_visiting_sms'] ?? true;
        _notifyPersonVisitingEmail = kioskOptionsData['notify_person_visiting_email'] ?? true;
        //options
        _enableVisitorSignIn = kioskOptionsData['enable_visitor_sign_in'] ?? true;
        _enableVisitorSignOut = kioskOptionsData['enable_visitor_sign_out'] ?? true;
        _enableVisitorDelivery = kioskOptionsData['enable_visitor_delivery'] ?? false;
        _enableContractorSignIn = kioskOptionsData['enable_contractor_sign_in'] ?? false;
        _enableContractorSignOut = kioskOptionsData['enable_contractor_sign_out'] ?? false;
        _enableVisitorRetrieveBadge = kioskOptionsData['enable_visitor_retrieve_badge'] ?? false;
      }

     
      // Check printer configuration
      if (_reqPrint) {
        // Step 1: Check if printer data exists in storage
        final printerData = await SecureStorageService.getLastPrinter().timeout(const Duration(seconds: 5));
        final paperTypeData = await SecureStorageService.getPaperType().timeout(const Duration(seconds: 5));

        if (printerData == null || paperTypeData == null) {
          // Printer data not found - show persistent error and continue without printing
          _isPrinterReady = false;
          _persistentErrorMessage = 'Printer not configured. Please configure in Admin Dashboard. Printing is disabled.';
          debugPrint('Printer not configured - continuing without printing');
          // Continue loading kiosk
        } else {
          // Step 2: Reconstruct printer info from saved data
          try {
            final savedModel = printerData['model'] as String? ?? '';
            final savedAddress = printerData['address'] as String? ?? '';

            // Find the printer model
            final model = brother.Model.getValues().firstWhere(
              (m) => m.getName() == savedModel,
              orElse: () => brother.Model.UNSUPPORTED,
            );

            if (model == brother.Model.UNSUPPORTED) {
              // Printer model unsupported - show persistent error and continue without printing
              _isPrinterReady = false;
              _persistentErrorMessage = 'Printer model not supported. Please reconfigure in Admin Dashboard. Printing is disabled.';
              debugPrint('Unsupported printer model: $savedModel - continuing without printing');
            } else {
              // Create printer info
              final printerInfo = brother.PrinterInfo()
                ..printerModel = model
                ..port = savedAddress == 'USB' ? brother.Port.USB : brother.Port.NET
                ..ipAddress = savedAddress != 'USB' ? savedAddress : '';

              // Load paper type
              final paperType = PrinterPaperType.fromJson(paperTypeData);
              printerInfo.labelNameIndex = paperType.labelNameIndex;
              // Step 3: Test printer connection
              try {
                final testPrinter = brother.Printer();
                await testPrinter.setPrinterInfo(printerInfo);
                final printerStatus = await testPrinter.getPrinterStatus();

                if (printerStatus.errorCode == brother.ErrorCode.ERROR_NONE) {
                  // Printer is reachable and ready
                  _isPrinterReady = true;
                  debugPrint('Printer is ready and reachable');
                } else if (printerStatus.errorCode == brother.ErrorCode.ERROR_COMMUNICATION_ERROR) {
                  // Printer configured but unreachable - show persistent error and continue
                  _isPrinterReady = false;
                  _persistentErrorMessage = 'Printer is unreachable. Please check printer connection. Printing is disabled.';
                  debugPrint('Printer communication error - continuing without printing capability');
                } else {
                  // Other printer errors - show persistent warning and continue
                  _isPrinterReady = false;
                  _persistentErrorMessage = 'Printer error: ${printerStatus.errorCode.getName()}. Printing is disabled.';
                  debugPrint('Printer status error: ${printerStatus.errorCode.getName()} - continuing without printing');
                }
              } catch (e, stackTrace) {
                // Connection test failed - show persistent error and continue
                _isPrinterReady = false;
                _persistentErrorMessage = 'Cannot connect to printer. Please check connection. Printing is disabled.';
                debugPrint('Printer connection test failed: $e');
                debugPrint('Stack trace: $stackTrace');
              }
            }
          } catch (e, stackTrace) {
            // Printer configuration error - show persistent error and continue
            _isPrinterReady = false;
            _persistentErrorMessage = 'Printer configuration error. Please reconfigure in Admin Dashboard. Printing is disabled.';
            debugPrint('Printer configuration error: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        }
      }
      // if this is equal to 'kiosk_dashboard' then skill to kiosk page
      await SecureStorageService.saveLastKioskAccess('kiosk_dashboard');

      _isCheckingInitial = false;
      notifyListeners();
    } on TimeoutException catch (e) {
      // Handle timeout errors
      debugPrint('Timeout error during initialization: $e');
      if (context != null && context.mounted) {
        context.showError('Request timed out. Please check your connection and try again.');
        await Future.delayed(const Duration(milliseconds: 800));
      }
      await onFailInitialization(AppRoutes.auth);
    } catch (e, stackTrace) {
      // Handle any other unexpected errors
      debugPrint('Unexpected error during initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context != null && context.mounted) {
        context.showError('Initialization failed. Please restart the app.');
        await Future.delayed(const Duration(milliseconds: 800));
      }
      await onFailInitialization(AppRoutes.auth);
    }
  }

  Future<void> logOutKioskDashboard() async {
    //false -> last access site
    await SecureStorageService.saveLastKioskAccess('none');
  }

}
