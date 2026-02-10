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
  //----------------------------------------------------
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

  // Printer settings
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  Future<void> initializing({
    required Future<void> Function(String nextRoute) onFailInitialization,
    BuildContext? context,
  }) async {
    try {
      // Load logos and background
      try {
        topLogo = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));
        bottomLogo = await SecureStorageService.getClientBottomLogoBytes().timeout(const Duration(seconds: 5));
        background = await SecureStorageService.getClientBackgroundBytes().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Failed to load logos/background: $e');
        // Continue without logos/background
      }

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

      //test select site--------------------- go to site page
      final savedSelectedSite = await SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite == null || savedSelectedSite.isEmpty) {
        // Show error BEFORE navigation
        if (context != null && context.mounted) {
          context.showError('Selected site issue, please reselect site');
          await Future.delayed(const Duration(milliseconds: 800));
        }
        await onFailInitialization(AppRoutes.newSite);
        return;
      }
      final currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
      currentSite = SiteItem.fromJson(currentSiteMap);

      //test admin settings----------------------------------------go to admin dashboard
      final kioskOptions = await SecureStorageService.getAdminDashboardSettings().timeout(const Duration(seconds: 5));
      //final selectedAdminPin = await SecureStorageService.getAdminPin().timeout(const Duration(seconds: 5));

      if (kioskOptions == null || kioskOptions.isEmpty) {
        if (context != null && context.mounted) {
          context.showError('Admin configuration issue, please complete setup in Admin Dashboard');
          await Future.delayed(const Duration(milliseconds: 800));
        }
        await onFailInitialization(AppRoutes.adminDashboard);
        return;
      }

      final kioskOptionsData = jsonDecode(kioskOptions) as Map<String, dynamic>;
      _enableVisitorSignIn = kioskOptionsData['enable_visitor_sign_in'] ?? true;
      _enableVisitorSignOut = kioskOptionsData['enable_visitor_sign_out'] ?? true;
      _enableVisitorDelivery = kioskOptionsData['enable_visitor_delivery'] ?? false;
      _enableContractorSignIn = kioskOptionsData['enable_contractor_sign_in'] ?? false;
      _enableContractorSignOut = kioskOptionsData['enable_contractor_sign_out'] ?? false;
      _enableVisitorRetrieveBadge = kioskOptionsData['enable_visitor_retrieve_badge'] ?? false;
      _reqPrint = kioskOptionsData['req_print'] ?? false;

      // Check printer configuration
      if (_reqPrint) {
        // Step 1: Check if printer data exists in storage
        final printerData = await SecureStorageService.getLastPrinter().timeout(const Duration(seconds: 5));
        final paperTypeData = await SecureStorageService.getPaperType().timeout(const Duration(seconds: 5));

        if (printerData == null || paperTypeData == null) {
          // Printer data not found - go back to admin
          if (context != null && context.mounted) {
            context.showError('Printer is required but not configured. Please configure printer in Admin Dashboard.');
            await Future.delayed(const Duration(milliseconds: 800));
          }
          await onFailInitialization(AppRoutes.adminDashboard);
          return;
        }
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
            if (context != null && context.mounted) {
              context.showError('Saved printer model is not supported. Please reconfigure in Admin Dashboard.');
              await Future.delayed(const Duration(milliseconds: 800));
            }
            await onFailInitialization(AppRoutes.adminDashboard);
            debugPrint('Unsupported printer model: $savedModel');
            return;
          }
          // Create printer info
          final printerInfo = brother.PrinterInfo()
            ..printerModel = model
            ..port = savedAddress == 'USB' ? brother.Port.USB : brother.Port.NET
            ..ipAddress = savedAddress != 'USB' ? savedAddress : '';

          // Load paper type
          final paperType = PrinterPaperType.fromJson(paperTypeData);
          printerInfo.labelNameIndex = paperType.labelNameIndex;
          // Step 3: Test printer connection
          final testPrinter = brother.Printer();
          await testPrinter.setPrinterInfo(printerInfo);
          final printerStatus = await testPrinter.getPrinterStatus();

          if (printerStatus.errorCode == brother.ErrorCode.ERROR_NONE) {
            // Printer is reachable and ready
            _isPrinterReady = true;
            debugPrint('Printer is ready and reachable');
          } else {
            // Printer has error - go back to admin
            if (context != null && context.mounted) {
              context.showError('Printer error: ${printerStatus.errorCode.getName()}. Please check printer in Admin Dashboard.');
              await Future.delayed(const Duration(milliseconds: 800));
            }
            await onFailInitialization(AppRoutes.adminDashboard);
            debugPrint('Printer status error: ${printerStatus.errorCode.getName()}');
            return;
          }
        } catch (e, stackTrace) {
          // Connection test failed - go back to admin
          if (context != null && context.mounted) {
            context.showError('Cannot connect to printer. Please check printer connection in Admin Dashboard.');
            await Future.delayed(const Duration(milliseconds: 800));
          }
          await onFailInitialization(AppRoutes.adminDashboard);
          debugPrint('Printer connection test failed: $e');
          debugPrint('Stack trace: $stackTrace');
          return;
        }
      } else {
        // Printing not required
        _isPrinterReady = false;
        debugPrint('ℹPrinting is disabled');
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
