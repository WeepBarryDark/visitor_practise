import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/notification_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSignOutController extends ChangeNotifier{
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Visitor Sign In';
    return _currentSite!.displayName;
  }


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

  // Notification configurations
  bool sendSms = true;
  bool sendEmail = true;

  final visitorIDCtl = TextEditingController();

  /// Initialize with data from KioskDashboardController (more efficient - reuses loaded data)
  Future<void> initialiseWithKioskController(dynamic kioskController) async {
    try {
      // Reuse already-loaded assets from kioskController
      topLogo = kioskController.topLogo;
      bottomLogo = kioskController.bottomLogo;
      background = kioskController.background;
      _currentSite = kioskController.currentSite;

      // Load notification configurations
      sendSms = kioskController.sendSms;
      sendEmail = kioskController.sendEmail;

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
      if (visitorIDCtl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Visitor ID is required');
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
        visitorId: visitorIDCtl.text.trim(),
        authToken: token,
      );

      // Check response
      if (response['success'] == true || response.containsKey('data')) {
        // Send sign-out notifications
        try {
          // Calculate visit duration
          final signInTime = DateTime.tryParse(_selectedVisitor?['sign_in_time'] ?? '');
          final signOutTime = DateTime.now();
          final duration = signInTime != null
            ? '${signOutTime.difference(signInTime).inMinutes} minutes'
            : 'Unknown';

          await NotificationService.sendSignOutNotifications(
            personVisitingId: _selectedVisitor?['contact_detail_id']?.toString() ?? '',
            personVisitingName: _selectedVisitor?['contact_detail_name'] ?? '',
            personVisitingEmail: _selectedVisitor?['contact_detail_email'] ?? '',
            personVisitingPhone: _selectedVisitor?['contact_detail_phone'] ?? '',
            visitorName: _selectedVisitor?['full_name'] ?? '',
            visitorCompany: _selectedVisitor?['company'] ?? '',
            siteName: _currentSite?.title ?? 'Site',
            signOutTime: signOutTime.toIso8601String(),
            duration: duration,
            authToken: token,
            sendSms: sendSms,
            sendEmail: sendEmail,
          );
        } catch (e) {
          debugPrint('Error sending sign-out notifications: $e');
        }

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
        final errorMsg = response['message']?.toString() ?? 'Failed to sign out visitor';
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