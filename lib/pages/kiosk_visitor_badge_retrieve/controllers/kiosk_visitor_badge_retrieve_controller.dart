import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/timezone_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorBadgeRetrieveController extends ChangeNotifier{
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Printer settings (from kiosk dashboard)
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Field configurations (from kiosk dashboard) - for default badge preview
  bool _reqFullName = true;
  bool _reqEmail = true;
  bool _reqPhone = false;
  bool _reqWorkType = false;
  bool _reqCompany = false;
  bool _reqAddress = false;
  bool _reqPersonVisiting = false;
  bool _reqSignInTime = false;
  bool _reqVisitorPhoto = false;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Badge Retrieve';
    return _currentSite!.displayName;
  }

  // Signed in visitors
  List<Map<String, dynamic>> _signedInVisitors = [];
  List<Map<String, dynamic>> get signedInVisitors => _signedInVisitors;

  // Selected visitor
  Map<String, dynamic>? _selectedVisitor;
  Map<String, dynamic>? get selectedVisitor => _selectedVisitor;

  // Badge preview
  Uint8List? _badgePreviewBytes;
  Uint8List? get badgePreviewBytes => _badgePreviewBytes;

  // Print progress
  PrintProgress _printProgress = PrintProgress.idle();
  PrintProgress get printProgress => _printProgress;

  // Status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  bool _isLoadingVisitors = false;
  bool get isLoadingVisitors => _isLoadingVisitors;

  bool _isGeneratingBadge = false;
  bool get isGeneratingBadge => _isGeneratingBadge;

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final visitorIdCtrl = TextEditingController();

  /// Initialize with data from KioskDashboardController (more efficient - reuses loaded data)
  Future<void> initialiseWithKioskController(KioskDashboardController kioskController) async {
    try {
      // Reuse already-loaded assets from kioskController
      topLogo = kioskController.topLogo;
      bottomLogo = kioskController.bottomLogo;
      background = kioskController.background;
      _currentSite = kioskController.currentSite;

      // Get printer settings
      _reqPrint = kioskController.reqPrint;
      _isPrinterReady = kioskController.isPrinterReady;

      // Get field configurations for default badge preview
      _reqFullName = kioskController.reqFullName;
      _reqEmail = kioskController.reqEmail;
      _reqPhone = kioskController.reqPhone;
      _reqWorkType = kioskController.reqWorkType;
      _reqCompany = kioskController.reqCompany;
      _reqAddress = kioskController.reqAddress;
      _reqPersonVisiting = kioskController.reqPersonVisiting;
      _reqSignInTime = kioskController.reqSignInTime;
      _reqVisitorPhoto = kioskController.reqVisitorPhoto;

      // Load signed in visitors
      await loadSignedInVisitors();

      // Generate default badge preview
      await _generateDefaultBadgePreview();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _isCheckingInitial = false;
      notifyListeners();
    }
  }

  /// Generate default badge preview based on required fields
  Future<void> _generateDefaultBadgePreview() async {
    try {
      final topLogoBytes = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));

      final formattedTime = _reqSignInTime
          ? TimezoneService.formatLocal(DateTime.now())
          : null;

      final badgeData = BadgeGenerator(
        visitorId: 'VIS000000000000',
        fullName: _reqFullName ? 'Visitor Name' : null,
        email: _reqEmail ? 'visitor@example.com' : null,
        phone: _reqPhone ? '+61 400 000 000' : null,
        workType: _reqWorkType ? 'Work Type' : null,
        company: _reqCompany ? 'Company Name' : null,
        address: _reqAddress ? '123 Example Street' : null,
        supervisor: _reqPersonVisiting ? 'Supervisor Name' : null,
        signInTime: formattedTime,
        siteName: _currentSite?.title ?? 'Site',
        clientLogoBytes: topLogoBytes,
        visitorPhotoBytes: null,
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

      _badgePreviewBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);
    } catch (e) {
      debugPrint('Error generating default badge preview: $e');
    }
  }

  /// Load signed in visitors from API
  Future<void> loadSignedInVisitors() async {
    try {
      _isLoadingVisitors = true;
      _errorMessage = null;
      notifyListeners();

      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isLoadingVisitors = false;
        notifyListeners();
        return;
      }

      // Fetch signed in visitors from API
      final response = await ApiService.fetchSignedInVisitors(
        token: token,
        siteId: _currentSite?.id ?? '',
      );

      debugPrint('Received ${response.length} signed-in visitors');

      // Parse and ensure we use visitor_id (VIS... format)
      _signedInVisitors = response.map((visitor) {
        // IMPORTANT: Use visitor_id (VIS...) NOT database id
        final visitorId = visitor['visitor_id']?.toString() ??
                         visitor['unique_id']?.toString() ??
                         visitor['id']?.toString() ?? '';

        // Create a normalized visitor map with visitor_id
        return {
          ...visitor,
          'visitor_id': visitorId,
          'display_name': visitor['full_name']?.toString() ??
                         visitor['name']?.toString() ??
                         'Unnamed Visitor',
          'display_info': 'ID: $visitorId${visitor['email']?.toString().isNotEmpty == true ? '\n${visitor['email']}' : ''}',
        };
      }).toList();

      _isLoadingVisitors = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visitors: $e');
      _errorMessage = 'Error loading visitors: $e';
      _isLoadingVisitors = false;
      notifyListeners();
    }
  }

  /// Look up visitor by ID (from QR scan or manual input)
  Future<void> lookupVisitorById(String visitorId, BuildContext context) async {
    if (visitorId.trim().isEmpty) {
      if (context.mounted) {
        context.showError('Please enter a visitor ID');
      }
      return;
    }

    final trimmedId = visitorId.trim();
    visitorIdCtrl.text = trimmedId;

    // Try to find visitor in already loaded list
    final found = _signedInVisitors.where((v) {
      final id = v['visitor_id']?.toString() ?? '';
      return id.toLowerCase() == trimmedId.toLowerCase();
    }).toList();

    if (found.isNotEmpty) {
      await selectVisitor(found.first, context);
    } else {
      // Visitor not found in current site's signed-in list
      if (context.mounted) {
        context.showError('Visitor ID not found in signed-in visitors');
      }
    }
  }

  /// Select a visitor and generate badge preview
  Future<void> selectVisitor(Map<String, dynamic> visitor, BuildContext context) async {
    try {
      _selectedVisitor = visitor;
      // IMPORTANT: Use visitor_id (VIS...) NOT database id
      final visitorId = visitor['visitor_id']?.toString() ??
                       visitor['unique_id']?.toString() ??
                       visitor['id']?.toString() ?? '';
      visitorIdCtrl.text = visitorId;
      notifyListeners();

      // Generate badge preview
      await generateBadgePreview(context);
    } catch (e) {
      debugPrint('Error selecting visitor: $e');
      if (context.mounted) {
        context.showError('Error selecting visitor: $e');
      }
    }
  }

  /// Generate badge preview from selected visitor data
  /// Shows all available fields from JSON (ignores required info settings)
  Future<void> generateBadgePreview(BuildContext context) async {
    if (_selectedVisitor == null) return;

    try {
      _isGeneratingBadge = true;
      _errorMessage = null;
      notifyListeners();

      // Get logo bytes
      final topLogoBytes = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));

      // IMPORTANT: Use visitor_id (VIS...) NOT database id
      final visitorId = _selectedVisitor!['visitor_id']?.toString() ??
                       _selectedVisitor!['unique_id']?.toString() ??
                       _selectedVisitor!['id']?.toString() ?? '';

      // Get values from visitor data
      final fullName = _selectedVisitor!['full_name']?.toString() ??
                      _selectedVisitor!['name']?.toString();
      final email = _selectedVisitor!['email']?.toString();
      final phone = _selectedVisitor!['phone']?.toString() ??
                   _selectedVisitor!['mobile']?.toString();
      final workType = _selectedVisitor!['work_type']?.toString() ??
                      _selectedVisitor!['type']?.toString();
      final company = _selectedVisitor!['company']?.toString() ??
                     _selectedVisitor!['organisation']?.toString();
      final address = _selectedVisitor!['address']?.toString();
      final supervisor = _selectedVisitor!['contact_detail_name']?.toString() ??
                        _selectedVisitor!['supervisor']?.toString();

      // Format sign in time (convert UTC to local timezone)
      final signInTimeStr = _selectedVisitor!['sign_in']?.toString() ??
                           _selectedVisitor!['sign_in_time']?.toString();
      String? formattedSignInTime;
      if (signInTimeStr != null && signInTimeStr.isNotEmpty) {
        final parsedTime = DateTime.tryParse(signInTimeStr);
        if (parsedTime != null) {
          // Convert UTC to local timezone before formatting
          final localTime = parsedTime.toLocal();
          formattedSignInTime = TimezoneService.formatLocal(localTime);
        }
      }

      // Show fields based on whether they have data (ignore required settings)
      final badgeData = BadgeGenerator(
        visitorId: visitorId,
        fullName: fullName,
        email: email,
        phone: phone,
        workType: workType,
        company: company,
        address: address,
        supervisor: supervisor,
        signInTime: formattedSignInTime,
        siteName: _currentSite?.title ?? 'Site',
        clientLogoBytes: topLogoBytes,
        visitorPhotoBytes: null, // Photo not stored in signed-in visitors data
        // Show all fields that have data
        showFullName: fullName != null && fullName.isNotEmpty,
        showEmail: email != null && email.isNotEmpty,
        showPhone: phone != null && phone.isNotEmpty,
        showWorkType: workType != null && workType.isNotEmpty,
        showCompany: company != null && company.isNotEmpty,
        showAddress: address != null && address.isNotEmpty,
        showSupervisor: supervisor != null && supervisor.isNotEmpty,
        showSignInTime: formattedSignInTime != null && formattedSignInTime.isNotEmpty,
        showVisitorPhoto: false, // No photo available in reprint
      );

      _badgePreviewBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);

      _isGeneratingBadge = false;
      notifyListeners();

      if (context.mounted) {
        context.showSuccess('Badge preview generated');
      }
    } catch (e) {
      debugPrint('Error generating badge preview: $e');
      _errorMessage = 'Failed to generate badge preview';
      _isGeneratingBadge = false;
      notifyListeners();

      if (context.mounted) {
        context.showError('Failed to generate badge preview: $e');
      }
    }
  }

  /// Reprint badge
  Future<void> reprintBadge(BuildContext context) async {
    if (_badgePreviewBytes == null) {
      if (context.mounted) {
        context.showError('No badge to print');
      }
      return;
    }

    try {
      _isPrinting = true;
      _printProgress = PrintProgress.connecting();
      notifyListeners();

      // Get printer info
      final printerData = await SecureStorageService.getLastPrinter().timeout(const Duration(seconds: 5));
      if (printerData == null) {
        throw Exception('Printer not configured');
      }

      final savedModel = printerData['model'] as String? ?? '';
      final savedAddress = printerData['address'] as String? ?? '';

      final model = brother.Model.getValues().firstWhere(
        (m) => m.getName() == savedModel,
        orElse: () => brother.Model.UNSUPPORTED,
      );

      if (model == brother.Model.UNSUPPORTED) {
        throw Exception('Unsupported printer model');
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

      final printer = brother.Printer();
      await printer.setPrinterInfo(printerInfo);

      _printProgress = PrintProgress.printing();
      notifyListeners();

      // Convert Uint8List to ui.Image for printing
      final ui.Codec codec = await ui.instantiateImageCodec(_badgePreviewBytes!);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image badgeImage = frameInfo.image;

      final result = await printer.printImage(badgeImage);

      if (result.errorCode == brother.ErrorCode.ERROR_NONE) {
        _printProgress = PrintProgress.completed();
        if (context.mounted) {
          context.showSuccess('Badge reprinted successfully');
        }
      } else {
        throw Exception('Print failed: ${result.errorCode.getName()}');
      }

      _isPrinting = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error reprinting badge: $e');
      _printProgress = PrintProgress.failed('Print error: $e');
      _isPrinting = false;
      notifyListeners();

      if (context.mounted) {
        context.showError('Failed to reprint badge: $e');
      }
    }
  }

  @override
  void dispose() {
    visitorIdCtrl.dispose();
    super.dispose();
  }
}