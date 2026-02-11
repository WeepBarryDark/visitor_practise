import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/timezone_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSignOutController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Visitor Sign Out';
    return _currentSite!.displayName;
  }

  // Printer settings (from kiosk dashboard)
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Signed in visitors
  List<Map<String, dynamic>> _signedInVisitors = [];
  List<Map<String, dynamic>> get signedInVisitors => _signedInVisitors;

  // Selected visitor
  Map<String, dynamic>? _selectedVisitor;
  Map<String, dynamic>? get selectedVisitor => _selectedVisitor;

  // Status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  bool _isLoadingVisitors = false;
  bool get isLoadingVisitors => _isLoadingVisitors;

  bool _submitting = false;
  bool get submitting => _submitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Notification configurations (from kiosk dashboard)
  bool _notifyPersonVisitingSms = false;
  bool get notifyPersonVisitingSms => _notifyPersonVisitingSms;

  bool _notifyPersonVisitingEmail = false;
  bool get notifyPersonVisitingEmail => _notifyPersonVisitingEmail;

  final visitorIDCtl = TextEditingController();

  /// Initialize with data from KioskDashboardController
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

      // Load notification configurations
      _notifyPersonVisitingSms = kioskController.notifyPersonVisitingSms;
      _notifyPersonVisitingEmail = kioskController.notifyPersonVisitingEmail;

      // Load signed in visitors
      await loadSignedInVisitors();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Failed to initialize: $e';
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

      // Parse and ensure we use visitor_id (VIS... format)
      _signedInVisitors = response.map((visitor) {
        // IMPORTANT: Use visitor_id (VIS...) NOT database id
        final visitorId = visitor['visitor_id']?.toString() ??
                         visitor['unique_id']?.toString() ??
                         visitor['id']?.toString() ?? '';

        final signInTime = visitor['sign_in_time']?.toString() ??
                          visitor['created_at']?.toString() ?? '';

        // Format sign in time for display
        String formattedSignInTime = '';
        if (signInTime.isNotEmpty) {
          final parsedTime = DateTime.tryParse(signInTime);
          if (parsedTime != null) {
            // Convert UTC to local timezone before formatting
            formattedSignInTime = TimezoneService.formatLocal(parsedTime.toLocal());
          } else {
            formattedSignInTime = signInTime;
          }
        }

        // Create a normalized visitor map with visitor_id
        return {
          ...visitor,
          'visitor_id': visitorId,
          'display_name': visitor['full_name']?.toString() ??
                         visitor['name']?.toString() ??
                         'Unnamed Visitor',
          'display_info': 'ID: $visitorId'
              '${visitor['email']?.toString().isNotEmpty == true ? '\nEmail: ${visitor['email']}' : ''}'
              '${formattedSignInTime.isNotEmpty ? '\nSigned in: $formattedSignInTime' : ''}',
          'formatted_sign_in_time': formattedSignInTime,
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

  /// Select a visitor from the list
  void selectVisitor(Map<String, dynamic> visitor) {
    _selectedVisitor = visitor;
    // IMPORTANT: Use visitor_id (VIS...) NOT database id
    final visitorId = visitor['visitor_id']?.toString() ??
                     visitor['unique_id']?.toString() ??
                     visitor['id']?.toString() ?? '';
    visitorIDCtl.text = visitorId;
    notifyListeners();
  }

  /// Submit sign-out
  Future<bool> submitSignOut(BuildContext context) async {
    try {
      _submitting = true;
      _errorMessage = null;
      notifyListeners();

      // Validate visitor ID
      final trimmedId = visitorIDCtl.text.trim();
      if (trimmedId.isEmpty) {
        if (context.mounted) context.showError('Visitor ID is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Refresh the signed-in visitors list first
      await loadSignedInVisitors();

      // Check if visitor is in the current signed-in list
      final visitorExists = _signedInVisitors.any((v) {
        final id = v['visitor_id']?.toString().toLowerCase() ?? '';
        return id == trimmedId.toLowerCase();
      });

      if (!visitorExists) {
        if (context.mounted) {
          context.showError('Visitor not found or already signed out');
        }
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Get auth token
      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        if (context.mounted) context.showError('Authentication token not found');
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Submit sign-out
      final response = await ApiService.signOutVisitor(
        visitorId: trimmedId,
        authToken: token,
      );

      debugPrint('Sign-out response: $response');

      // Check response - only success if API explicitly returns success: true
      // Also check for error messages like "already signed out", "not found", etc.
      final message = response['message']?.toString().toLowerCase() ?? '';
      final hasError = message.contains('already') ||
                       message.contains('not found') ||
                       message.contains('invalid') ||
                       message.contains('error') ||
                       message.contains('fail');

      if (response['success'] == true && !hasError) {
        // Send sign-out notifications if configured
        /*
        if (_notifyPersonVisitingSms || _notifyPersonVisitingEmail) {
          try {
            // Calculate visit duration
            final signInTimeStr = _selectedVisitor?['sign_in_time']?.toString() ??
                                 _selectedVisitor?['created_at']?.toString() ?? '';
            final signInTime = DateTime.tryParse(signInTimeStr);
            final signOutTime = DateTime.now();
            String duration = 'Unknown';
            if (signInTime != null) {
              final diff = signOutTime.difference(signInTime);
              if (diff.inHours > 0) {
                duration = '${diff.inHours}h ${diff.inMinutes % 60}m';
              } else {
                duration = '${diff.inMinutes} minutes';
              }
            }

            I/flutter (11682): contact_detail_id: null
            I/flutter (11682): contact_detail_name: null
            I/flutter (11682): contact_detail_email: null
            I/flutter (11682): contact_detail_phone: null
            
            await NotificationService.sendSignOutNotifications(
              personVisitingId: _selectedVisitor?['contact_detail_id']?.toString() ?? '',
              personVisitingName: _selectedVisitor?['contact_detail_name']?.toString() ??
                                 _selectedVisitor?['supervisor']?.toString() ?? '',
              personVisitingEmail: _selectedVisitor?['contact_detail_email']?.toString() ?? '',
              personVisitingPhone: _selectedVisitor?['contact_detail_phone']?.toString() ?? '',
              visitorName: _selectedVisitor?['full_name']?.toString() ??
                          _selectedVisitor?['name']?.toString() ?? '',
              visitorCompany: _selectedVisitor?['company']?.toString() ??
                             _selectedVisitor?['organisation']?.toString() ?? '',
              siteName: _currentSite?.title ?? 'Site',
              signOutTime: TimezoneService.formatLocal(signOutTime),
              duration: duration,
              authToken: token,
              sendSms: _notifyPersonVisitingSms,
              sendEmail: _notifyPersonVisitingEmail,
            );
          } catch (e) {
            debugPrint('Error sending sign-out notifications: $e');
          }
        } */

        // Clear form and selected visitor
        visitorIDCtl.clear();
        _selectedVisitor = null;

        // Show success message
        if (context.mounted) {
          context.showSuccess('Visitor signed out successfully');
        }

        _submitting = false;
        notifyListeners();

        // Reload visitor list to refresh data
        await loadSignedInVisitors();

        return true;
      } else {
        final errorMsg = response['message']?.toString() ??
                        response['error']?.toString() ??
                        'Failed to sign out visitor';
        if (context.mounted) context.showError(errorMsg);
        _errorMessage = errorMsg;
        _submitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error signing out visitor: $e');
      if (context.mounted) {
        context.showError('Error signing out: $e');
      }
      _errorMessage = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    visitorIDCtl.dispose();
    super.dispose();
  }
}
