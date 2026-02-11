import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';
import 'dart:convert';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';

class KioskVisitorFinalBadgeController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Visitor and badge data
  VisitorData? _visitorData;
  VisitorData? get visitorData => _visitorData;

  Uint8List? _badgeImageBytes;
  Uint8List? get badgeImageBytes => _badgeImageBytes;

  // Print status
  PrintProgress _printProgress = PrintProgress.idle();
  PrintProgress get printProgress => _printProgress;

  String? _printErrorMessage;
  String? get printErrorMessage => _printErrorMessage;

  bool _isPrintComplete = false;
  bool get isPrintComplete => _isPrintComplete;

  // Status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Notification configurations
  bool _sendSms = true;
  bool get sendSms => _sendSms;

  bool _sendEmail = true;
  bool get sendEmail => _sendEmail;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Visitor Badge';
    return _currentSite!.displayName;
  }

  /// Initialize with visitor data and badge image
  Future<void> initialise(VisitorData visitorData, Uint8List badgeImageBytes, BuildContext context) async {
    try {
      _visitorData = visitorData;
      _badgeImageBytes = badgeImageBytes;

      // Load logos and background
      topLogo = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));
      bottomLogo = await SecureStorageService.getClientBottomLogoBytes().timeout(const Duration(seconds: 5));
      background = await SecureStorageService.getClientBackgroundBytes().timeout(const Duration(seconds: 5));

      // Load current site for notifications
      final savedSelectedSite = await SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite != null && savedSelectedSite.isNotEmpty) {
        final currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
        _currentSite = SiteItem.fromJson(currentSiteMap);
      }

      // Check if printing is required and load notification configs
      final kioskOptions = await SecureStorageService.getAdminDashboardSettings().timeout(const Duration(seconds: 5));
      if (kioskOptions != null && kioskOptions.isNotEmpty) {
        final kioskOptionsData = jsonDecode(kioskOptions) as Map<String, dynamic>;
        _reqPrint = kioskOptionsData['req_print'] ?? false;
        _sendSms = kioskOptionsData['send_sms'] ?? true;
        _sendEmail = kioskOptionsData['send_email'] ?? true;
      }

      // Check printer readiness if required
      if (_reqPrint) {
        final printerData = await SecureStorageService.getLastPrinter().timeout(const Duration(seconds: 5));
        _isPrinterReady = printerData != null;
      }

      _isCheckingInitial = false;
      notifyListeners();

      // Auto-print if printer is ready
      if (_reqPrint && _isPrinterReady) {
        await printBadge(context);
      } else if (_reqPrint && !_isPrinterReady) {
        if (context.mounted) {
          context.showError('Printer not ready. Badge will not be printed.');
        }
        _isPrintComplete = true; // Allow user to continue
        notifyListeners();
      } else {
        // Printing not required, mark as complete
        _isPrintComplete = true;
        notifyListeners();
      }

      // Note: Notifications are already sent in Site Questions Controller
      // after successful API submission. No need to send again here.
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _isCheckingInitial = false;
      _isPrintComplete = true; // Allow user to continue on error
      notifyListeners();
    }
  }

  /// Print the badge
  Future<void> printBadge(BuildContext context) async {
    if (_badgeImageBytes == null) {
      if (context.mounted) {
        context.showError('Badge image not available');
      }
      return;
    }

    try {
      _printProgress = PrintProgress.connecting();
      _printErrorMessage = null;
      notifyListeners();

      // Get printer info from storage
      final printerData = await SecureStorageService.getLastPrinter().timeout(const Duration(seconds: 5));
      if (printerData == null) {
        throw Exception('Printer configuration not found');
      }

      final savedModel = printerData['model'] as String? ?? '';
      final savedAddress = printerData['address'] as String? ?? '';

      // Find the printer model
      final model = brother.Model.getValues().firstWhere(
        (m) => m.getName() == savedModel,
        orElse: () => brother.Model.UNSUPPORTED,
      );

      if (model == brother.Model.UNSUPPORTED) {
        throw Exception('Unsupported printer model: $savedModel');
      }

      // Load saved paper type
      final paperTypeData = await SecureStorageService.getPaperType().timeout(const Duration(seconds: 5));
      if (paperTypeData == null) {
        throw Exception('Paper type not configured. Please configure in Admin Dashboard.');
      }

      final paperType = PrinterPaperType.fromJson(paperTypeData);
      debugPrint('Using paper type: ${paperType.code} (labelNameIndex: ${paperType.labelNameIndex})');

      // Create printer info with paper type
      final printerInfo = brother.PrinterInfo()
        ..printerModel = model
        ..port = savedAddress == 'USB' ? brother.Port.USB : brother.Port.NET
        ..ipAddress = savedAddress != 'USB' ? savedAddress : ''
        ..labelNameIndex = paperType.labelNameIndex;

      _printProgress = PrintProgress.sending();
      notifyListeners();

      // Print the badge
      final printer = brother.Printer();
      await printer.setPrinterInfo(printerInfo);

      _printProgress = PrintProgress.printing();
      notifyListeners();

      // Convert Uint8List to ui.Image for printing
      final ui.Codec codec = await ui.instantiateImageCodec(_badgeImageBytes!);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image badgeImage = frameInfo.image;

      final result = await printer.printImage(badgeImage);

      if (result.errorCode == brother.ErrorCode.ERROR_NONE) {
        _printProgress = PrintProgress.completed();
        _isPrintComplete = true;
        if (context.mounted) {
          context.showSuccess('Badge printed successfully');
        }

        // Auto-return to dashboard after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.kioskDashboard,
              (route) => false,
            );
          }
        });
      } else {
        throw Exception('Print failed: ${result.errorCode.getName()}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error printing badge: $e');
      _printProgress = PrintProgress.failed('Print failed: $e');
      _printErrorMessage = e.toString();
      _isPrintComplete = true; // Allow user to continue despite error

      if (context.mounted) {
        context.showError('Print failed: $e');
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}