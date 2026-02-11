import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/notification_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskDeliveriesController extends ChangeNotifier {
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Contacts
  List<ContactDetail> _availableContacts = [];
  List<ContactDetail> get availableContacts => _availableContacts;

  // Form controller - ONLY delivery company
  final TextEditingController orgCtrl = TextEditingController();

  // Status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;

  bool _isLoadingContacts = false;
  bool get isLoadingContacts => _isLoadingContacts;

  bool _submitting = false;
  bool get submitting => _submitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Notification configurations
  bool sendSms = true;
  bool sendEmail = true;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Deliveries';
    return _currentSite!.displayName;
  }

  /// Initialize with data from KioskDashboardController
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

      // Load contacts
      await loadContacts();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Failed to initialize: $e';
      _isCheckingInitial = false;
      notifyListeners();
    }
  }

  /// Load contacts from API
  Future<void> loadContacts() async {
    try {
      _isLoadingContacts = true;
      _errorMessage = null;
      notifyListeners();

      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isLoadingContacts = false;
        notifyListeners();
        return;
      }

      // Fetch contacts from API
      final response = await ApiService.fetchVisitorContacts(token);

      if (response['data'] != null) {
        final List<dynamic> contactsData = response['data'] as List<dynamic>;
        _availableContacts = contactsData
            .map((json) => ContactDetail.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = 'Failed to load contacts';
      }

      _isLoadingContacts = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      _errorMessage = 'Error loading contacts: $e';
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  /// Submit delivery notification (does NOT save to database)
  Future<bool> submitDelivery(BuildContext context) async {
    try {
      _submitting = true;
      _errorMessage = null;
      notifyListeners();

      // Validate delivery company
      if (orgCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Delivery company is required');
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

      final company = orgCtrl.text.trim();
      final siteName = getSiteTitle();

      // Find site supervisor in contacts list
      ContactDetail? supervisor;
      if (_currentSite != null && _availableContacts.isNotEmpty) {
        try {
          supervisor = _availableContacts.firstWhere(
            (contact) => contact.name == _currentSite!.siteSupervisor.name,
          );
          debugPrint('Found supervisor: ${supervisor.name} (Email: ${supervisor.email}, Phone: ${supervisor.phone})');
        } catch (e) {
          debugPrint('Warning: Site supervisor "${_currentSite!.siteSupervisor.name}" not found in contacts list');
        }
      }

      if (supervisor == null) {
        if (context.mounted) context.showError('Site supervisor contact information not available');
        _submitting = false;
        notifyListeners();
        return false;
      }

      bool smsSuccess = true;
      bool emailSuccess = true;

      // Send SMS notification if enabled
      if (sendSms && supervisor.phone.trim().isNotEmpty) {
        debugPrint('Sending SMS to supervisor: ${supervisor.phone}');
        final smsMessage = 'A delivery from $company has arrived at $siteName.';
        smsSuccess = await NotificationService.sendSMS(
          userId: supervisor.id,
          phone: supervisor.phone,
          message: smsMessage,
          authToken: token,
        );
        debugPrint('SMS send result: ${smsSuccess ? "SUCCESS" : "FAILED"}');
      }

      // Send Email notification if enabled
      if (sendEmail && supervisor.email.trim().isNotEmpty) {
        debugPrint('Sending Email to supervisor: ${supervisor.email}');
        final emailBody = '''
Hello ${supervisor.name},

A delivery has arrived at $siteName.

Delivery Details:
- Delivery Company: $company
- Arrival Time: ${DateTime.now().toString().split('.')[0]}

Please collect the delivery from the reception.

This is an automated message from the Visitor Management System.
''';
        emailSuccess = await NotificationService.sendEmail(
          userId: supervisor.id,
          name: supervisor.name,
          email: supervisor.email,
          phone: supervisor.phone,
          message: emailBody,
          authToken: token,
        );
        debugPrint('Email send result: ${emailSuccess ? "SUCCESS" : "FAILED"}');
      }

      if (context.mounted) {
        if (smsSuccess && emailSuccess) {
          context.showSuccess('Supervisor notified successfully!');
        } else {
          context.showError('Some notifications failed to send');
        }
      }

      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error submitting delivery: $e');
      if (context.mounted) {
        context.showError('Error: $e');
      }
      _errorMessage = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear form
  void clearForm() {
    orgCtrl.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    orgCtrl.dispose();
    super.dispose();
  }
}
