import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/notification_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/timezone_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskDeliveriesController extends ChangeNotifier {
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

  // Notification configurations (delivery specific)
  bool _notifyDeliverySms = false;
  bool get notifyDeliverySms => _notifyDeliverySms;

  bool _notifyDeliveryEmail = false;
  bool get notifyDeliveryEmail => _notifyDeliveryEmail;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Deliveries';
    return _currentSite!.displayName;
  }

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

      // Load notification configurations (delivery specific)
      _notifyDeliverySms = kioskController.notifyDeliverySms;
      _notifyDeliveryEmail = kioskController.notifyDeliveryEmail;

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

      // Get supervisor info from site
      if (_currentSite == null) {
        if (context.mounted) context.showError('Site information not available');
        _submitting = false;
        notifyListeners();
        return false;
      }

      final supervisorId = _currentSite!.siteSupervisor.id.toString();
      final supervisorName = _currentSite!.siteSupervisor.name;

      // Find supervisor's email and phone from contacts list
      String supervisorEmail = '';
      String supervisorPhone = '';

      if (_availableContacts.isNotEmpty) {
        try {
          final supervisorContact = _availableContacts.firstWhere(
            (contact) => contact.id == supervisorId || contact.name == supervisorName,
          );
          supervisorEmail = supervisorContact.email;
          supervisorPhone = supervisorContact.phone;
        } catch (e) {
          // Supervisor not found in contacts - notifications will be skipped
        }
      }

      bool smsSuccess = true;
      bool emailSuccess = true;
      bool notificationAttempted = false;

      // Send SMS notification if enabled and phone available
      if (_notifyDeliverySms && supervisorPhone.trim().isNotEmpty) {
        notificationAttempted = true;
        final smsMessage = 'A delivery from $company has arrived at $siteName.';
        smsSuccess = await NotificationService.sendSMS(
          userId: supervisorId,
          phone: supervisorPhone,
          message: smsMessage,
          authToken: token,
        );
      }

      // Send Email notification if enabled and email available
      if (_notifyDeliveryEmail && supervisorEmail.trim().isNotEmpty) {
        notificationAttempted = true;
        final arrivalTime = TimezoneService.formatLocal(DateTime.now());
        final emailBody = '''
Hello $supervisorName,

A delivery has arrived at $siteName.

Delivery Details:
- Delivery Company: $company
- Arrival Time: $arrivalTime

Please collect the delivery from the reception.

This is an automated message from the Visitor Management System.
''';
        emailSuccess = await NotificationService.sendEmail(
          userId: supervisorId,
          name: supervisorName,
          email: supervisorEmail,
          phone: supervisorPhone,
          message: emailBody,
          authToken: token,
        );
      }

      if (context.mounted) {
        if (!notificationAttempted) {
          context.showSuccess('Delivery recorded (no notification sent - supervisor contact info not available)');
        } else if (smsSuccess && emailSuccess) {
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
