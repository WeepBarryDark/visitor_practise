import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorBadgeRetrieveController extends ChangeNotifier{
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

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
  Future<void> initialiseWithKioskController(dynamic kioskController) async {
    try {
      // Reuse already-loaded assets from kioskController
      topLogo = kioskController.topLogo;
      bottomLogo = kioskController.bottomLogo;
      background = kioskController.background;
      _currentSite = kioskController.currentSite;

      // Load signed in visitors
      await loadSignedInVisitors();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _isCheckingInitial = false;
      notifyListeners();
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

      debugPrint('Parsed ${_signedInVisitors.length} visitors successfully');

      _isLoadingVisitors = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visitors: $e');
      _errorMessage = 'Error loading visitors: $e';
      _isLoadingVisitors = false;
      notifyListeners();
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

  /// Generate badge preview
  Future<void> generateBadgePreview(BuildContext context) async {
    if (_selectedVisitor == null) return;

    try {
      _isGeneratingBadge = true;
      _errorMessage = null;
      notifyListeners();

      // Get logo bytes
      final topLogoBytes = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));

      // Create BadgeGenerator model
      // IMPORTANT: Use visitor_id (VIS...) NOT database id
      final visitorId = _selectedVisitor!['visitor_id']?.toString() ??
                       _selectedVisitor!['unique_id']?.toString() ??
                       _selectedVisitor!['id']?.toString() ?? '';

      final badgeData = BadgeGenerator(
        visitorId: visitorId,
        fullName: _selectedVisitor!['full_name']?.toString() ?? _selectedVisitor!['name']?.toString() ?? '',
        email: _selectedVisitor!['email']?.toString() ?? '',
        phone: _selectedVisitor!['phone']?.toString() ?? _selectedVisitor!['mobile']?.toString() ?? '',
        workType: _selectedVisitor!['work_type']?.toString() ?? _selectedVisitor!['type']?.toString() ?? '',
        company: _selectedVisitor!['company']?.toString() ?? _selectedVisitor!['organisation']?.toString() ?? '',
        address: _selectedVisitor!['address']?.toString() ?? '',
        supervisor: _selectedVisitor!['contact_detail_name']?.toString() ?? '',
        signInTime: _selectedVisitor!['sign_in_time']?.toString() ?? '',
        siteName: _currentSite?.title ?? 'Site',
        clientLogoBytes: topLogoBytes,
        visitorPhotoBytes: null, // Photo not stored in signed-in visitors data
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