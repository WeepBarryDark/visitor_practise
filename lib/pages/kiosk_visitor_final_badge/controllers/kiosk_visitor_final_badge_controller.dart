import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/notification_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

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

  // Agree data for API submission
  Map<String, dynamic> _agreeData = {};

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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isSubmitted = false;
  bool get isSubmitted => _isSubmitted;

  bool _isGeneratingBadge = false;
  bool get isGeneratingBadge => _isGeneratingBadge;

  // Printer settings (from previous controller)
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Field configurations for badge generation
  bool _reqFullName = true;
  bool _reqEmail = true;
  bool _reqPhone = false;
  bool _reqWorkType = false;
  bool _reqCompany = false;
  bool _reqAddress = false;
  bool _reqPersonVisiting = false;
  bool _reqSignInTime = false;
  bool _reqVisitorPhoto = false;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Visitor Badge';
    return _currentSite!.displayName;
  }

  /// Initialize with data from SiteQuestionsController (reuses loaded data)
  Future<void> initialiseWithSiteQuestionsController(
    KioskVisitorSiteQuestionsController siteQuestionsController,
    BuildContext context,
  ) async {
    try {
      // Get data from siteQuestionsController
      _visitorData = siteQuestionsController.visitorData;
      _agreeData = siteQuestionsController.buildAgreeData();

      // Reuse already-loaded assets
      topLogo = siteQuestionsController.topLogo;
      bottomLogo = siteQuestionsController.bottomLogo;
      background = siteQuestionsController.background;
      _currentSite = siteQuestionsController.currentSite;

      // Get printer settings
      _reqPrint = siteQuestionsController.reqPrint;
      _isPrinterReady = siteQuestionsController.isPrinterReady;

      // Get field configurations for badge
      _reqFullName = siteQuestionsController.reqFullName;
      _reqEmail = siteQuestionsController.reqEmail;
      _reqPhone = siteQuestionsController.reqPhone;
      _reqWorkType = siteQuestionsController.reqWorkType;
      _reqCompany = siteQuestionsController.reqCompany;
      _reqAddress = siteQuestionsController.reqAddress;
      _reqPersonVisiting = siteQuestionsController.reqPersonVisiting;
      _reqSignInTime = siteQuestionsController.reqSignInTime;
      _reqVisitorPhoto = siteQuestionsController.reqVisitorPhoto;

      _isCheckingInitial = false;
      notifyListeners();

      // Start the flow: Submit API first, then generate badge, then print
      await _processSignIn(context);
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Initialization failed: $e';
      _isCheckingInitial = false;
      _isPrintComplete = true; // Allow user to return
      notifyListeners();
    }
  }

  /// Process sign-in flow: 1. Submit API → 2. Generate Badge → 3. Print (if required)
  Future<void> _processSignIn(BuildContext context) async {
    // STEP 1: Submit to API first
    final submitSuccess = await _submitLedger(context);
    if (!submitSuccess) {
      // API submission failed - don't generate badge
      return;
    }

    // STEP 2: Generate badge (only after successful API submission)
    final badgeSuccess = await _generateBadge(context);
    if (!badgeSuccess) {
      // Badge generation failed
      return;
    }

    // STEP 3: Send notifications
    await _sendNotifications(context);

    // STEP 4: Print badge (if required)
    if (_reqPrint) {
      if (_isPrinterReady) {
        await _printBadge(context);
      } else {
        // Printer not ready
        if (context.mounted) {
          context.showError('Printer not ready. Badge will not be printed.');
        }
        _isPrintComplete = true;
        notifyListeners();
      }
    } else {
      // Printing not required, mark as complete
      _isPrintComplete = true;
      notifyListeners();
    }
  }

  /// Submit sign-in to API
  Future<bool> _submitLedger(BuildContext context) async {
    if (_visitorData == null) {
      if (context.mounted) {
        context.showError('Visitor data not available');
      }
      return false;
    }

    try {
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      // Get auth token
      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        if (context.mounted) context.showError('Authentication token not found');
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Generate unique visitor ID
      final uniqueId = 'VIS${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';

      // Submit to API
      final response = await ApiService.submitSignInLedger(
        token: token,
        siteId: _visitorData!.siteId,
        name: _visitorData!.fullName,
        email: _visitorData!.email,
        questions: _agreeData,
        uniqueId: uniqueId,
        organisation: _visitorData!.company,
        phone: _visitorData!.phone,
        address: _visitorData!.address,
        workType: _visitorData!.workType,
        supervisor: _visitorData!.contactDetailName,
        signInTime: _visitorData!.signInTime,
        visitorPhotoBytes: _visitorData!.visitorPhotoBytes,
        visitorPhotoFilename: _visitorData!.visitorPhotoBytes != null ? 'visitor_photo.jpg' : null,
      );

      // Check for errors
      if (response.containsKey('error')) {
        final errorMsg = response['error'].toString();
        if (context.mounted) context.showError(errorMsg);
        _errorMessage = errorMsg;
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Get server-assigned visitor ID
      final serverVisitorId = response['visitor_id']?.toString() ??
                             response['unique_id']?.toString() ??
                             uniqueId;

      // Update visitor data with server ID
      _visitorData = _visitorData!.copyWith(visitorId: serverVisitorId);

      _isSubmitting = false;
      _isSubmitted = true;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error submitting sign-in: $e');
      _errorMessage = 'Failed to submit: $e';
      _isSubmitting = false;
      notifyListeners();

      if (context.mounted) {
        context.showError('Failed to submit: $e');
      }

      return false;
    }
  }

  /// Generate badge image
  Future<bool> _generateBadge(BuildContext context) async {
    try {
      _isGeneratingBadge = true;
      notifyListeners();

      final badgeData = BadgeGenerator(
        visitorId: _visitorData!.visitorId ?? 'VISITOR',
        fullName: _visitorData!.fullName,
        email: _visitorData!.email,
        phone: _visitorData!.phone,
        workType: _visitorData!.workType,
        company: _visitorData!.company,
        address: _visitorData!.address,
        supervisor: _visitorData!.contactDetailName,
        signInTime: _visitorData!.signInTime,
        siteName: _currentSite?.title ?? 'Site',
        clientLogoBytes: topLogo,
        visitorPhotoBytes: _visitorData!.visitorPhotoBytes,
        // Field configurations - only show required fields
        showFullName: _reqFullName,
        showEmail: _reqEmail,
        showPhone: _reqPhone,
        showWorkType: _reqWorkType,
        showCompany: _reqCompany,
        showAddress: _reqAddress,
        showSupervisor: _reqPersonVisiting,
        showSignInTime: _reqSignInTime,
        showVisitorPhoto: _reqVisitorPhoto,
      );

      _badgeImageBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);

      _isGeneratingBadge = false;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error generating badge: $e');
      _errorMessage = 'Failed to generate badge: $e';
      _isGeneratingBadge = false;
      notifyListeners();

      if (context.mounted) {
        context.showError('Failed to generate badge: $e');
      }

      return false;
    }
  }

  /// Send notifications to Person Visiting
  Future<void> _sendNotifications(BuildContext context) async {
    if (_visitorData == null) return;

    final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
    if (token == null || token.isEmpty) return;

    if (_visitorData!.notifyPersonVisitingSms || _visitorData!.notifyPersonVisitingEmail) {
      try {
        await NotificationService.sendSignInNotifications(
          personVisitingId: _visitorData!.contactDetailId,
          personVisitingName: _visitorData!.contactDetailName,
          personVisitingEmail: _visitorData!.contactDetailEmail,
          personVisitingPhone: _visitorData!.contactDetailPhone,
          visitorName: _visitorData!.fullName,
          visitorCompany: _visitorData!.company,
          visitorEmail: _visitorData!.email,
          visitorPhone: _visitorData!.phone,
          siteName: _currentSite?.title ?? 'Site',
          signInTime: _visitorData!.signInTime,
          authToken: token,
          sendSms: _visitorData!.notifyPersonVisitingSms,
          sendEmail: _visitorData!.notifyPersonVisitingEmail,
        );
      } catch (e) {
        debugPrint('Error sending notifications: $e');
        // Continue even if notifications fail
      }
    }
  }

  /// Print the badge
  Future<void> _printBadge(BuildContext context) async {
    if (_badgeImageBytes == null) {
      if (context.mounted) {
        context.showError('Badge image not available');
      }
      _printProgress = PrintProgress.failed('Badge image not available');
      _isPrintComplete = true;
      notifyListeners();
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
        throw Exception('Paper type not configured');
      }

      final paperType = PrinterPaperType.fromJson(paperTypeData);
      debugPrint('Using paper type: ${paperType.code} (labelNameIndex: ${paperType.labelNameIndex})');

      // Create printer info
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
      } else {
        throw Exception('Print failed: ${result.errorCode.getName()}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error printing badge: $e');
      _printProgress = PrintProgress.failed('Print failed: $e');
      _printErrorMessage = e.toString();
      _isPrintComplete = true;

      if (context.mounted) {
        context.showError('Print failed: $e');
      }

      notifyListeners();
    }
  }

  /// Manual retry for printing
  Future<void> retryPrint(BuildContext context) async {
    await _printBadge(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
