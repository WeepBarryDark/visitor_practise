import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/network_service.dart';
import 'package:visitor_practise/services/timezone_service.dart';
import 'package:visitor_practise/services/helper/validation_helper.dart';
import 'package:visitor_practise/services/helper/image_helper.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSignInController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

    // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;

  //-------------------------------------all status
  // Printer settings
  bool reqPrint = false;
  bool isPrinterReady = false;

  // Field configurations (from KioskDashboard) - loaded during initialization
  bool reqFullName = true;
  bool reqEmail = true;
  bool reqPhone = false;
  bool reqWorkType = false;
  bool reqCompany = false;
  bool reqAddress = false;
  bool reqPersonVisiting = false;
  bool reqSignInTime = false;
  bool reqVisitorPhoto = false;

  // Notification configurations
  bool notifyPersonVisitingSms = false;
  bool notifyPersonVisitingEmail = false;

  //-----------------------------------------------------
  // Contact details
  List<ContactDetail> _availableContacts = [];
  List<ContactDetail> get availableContacts => _availableContacts;
  ContactDetail? _selectedContact;
  ContactDetail? get selectedContact => _selectedContact;

  // Visitor photo
  Uint8List? _visitorPhotoBytes;
  Uint8List? get visitorPhotoBytes => _visitorPhotoBytes;
  bool get hasPhoto => _visitorPhotoBytes != null;

  // Loading states
  bool _isLoadingContacts = false;
  bool get isLoadingContacts => _isLoadingContacts;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Visitor Sign In';
    return _currentSite!.displayName;
  }

  // Timer for real-time clock update
  Timer? _timeUpdateTimer;

  //All input fields
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final workTypeCtrl = TextEditingController();
  final TextEditingController signInTimeCtrl = TextEditingController();

  /// Initialize with data from KioskDashboardController (more efficient - reuses loaded data)
  /// Returns true if successful, false if failed
  Future<bool> initialiseWithKioskController(KioskDashboardController kioskController) async {
    topLogo = kioskController.topLogo;
    bottomLogo = kioskController.bottomLogo;
    background = kioskController.background;
    try {
      // Reuse already-loaded assets from kioskController
      _currentSite = kioskController.currentSite;
      // Print setting
      reqPrint = kioskController.reqPrint;
      isPrinterReady = kioskController.isPrinterReady;
      // Load field configurations from kioskController
      reqFullName = kioskController.reqFullName;
      reqEmail = kioskController.reqEmail;
      reqPhone = kioskController.reqPhone;
      reqCompany = kioskController.reqCompany;
      reqAddress = kioskController.reqAddress;
      reqWorkType = kioskController.reqWorkType;
      reqPersonVisiting = kioskController.reqPersonVisiting;
      reqSignInTime = kioskController.reqSignInTime;
      reqVisitorPhoto = kioskController.reqVisitorPhoto;

      notifyPersonVisitingEmail = kioskController.notifyPersonVisitingEmail;
      notifyPersonVisitingSms = kioskController.notifyPersonVisitingSms;

      // Load contacts - if fails, return false
      final contactsLoaded = await loadContacts();
      if (!contactsLoaded) {
        _isCheckingInitial = false;
        notifyListeners();
        return false;
      }

      // Auto-fill and update sign-in time using TimezoneService
      final snapshot = TimezoneService.captureNow();
      signInTimeCtrl.text = TimezoneService.formatLocal(snapshot.localTime);

      // Start timer to update time every second
      _timeUpdateTimer?.cancel();
      _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentSnapshot = TimezoneService.captureNow();
        signInTimeCtrl.text = TimezoneService.formatLocal(currentSnapshot.localTime);
        notifyListeners();
      });

      _isCheckingInitial = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Initialization failed: $e';
      _isCheckingInitial = false;
      notifyListeners();
      return false;
    }
  }

  /// Load contacts from API
  /// Returns true if successful, false if failed
  Future<bool> loadContacts() async {
    try {
      _isLoadingContacts = true;
      _errorMessage = null;
      notifyListeners();

      // Check network connectivity before making API call
      if (!NetworkService.isOnline) {
        _errorMessage = 'No internet connection. Please check your network.';
        _isLoadingContacts = false;
        notifyListeners();
        return false;
      }

      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found. Please sign in again.';
        _isLoadingContacts = false;
        notifyListeners();
        return false;
      }

      // Fetch contacts from API
      final response = await ApiService.fetchVisitorContacts(token);
      if (response['data'] != null) {
        final List<dynamic> contactsData = response['data'] as List<dynamic>;
        _availableContacts = contactsData
            .map((json) => ContactDetail.fromMap(json as Map<String, dynamic>))
            .toList();

        _isLoadingContacts = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load contacts from server';
        _isLoadingContacts = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      _errorMessage = 'Error loading contacts: $e';
      _isLoadingContacts = false;
      notifyListeners();
      return false;
    }
  }

  /// Select a contact from the list
  void selectContact(ContactDetail contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  /// Capture visitor photo using camera
  Future<void> captureVisitorPhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        // Read image bytes
        final bytes = await photo.readAsBytes();

        // Compress image in separate isolate to avoid UI blocking
        _visitorPhotoBytes = await compute(compressImageInIsolate, bytes);

        if (context.mounted) {
          context.showSuccess('Photo captured successfully');
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (context.mounted) {
        context.showError('Failed to capture photo: $e');
      }
    }
  }

  /// Validate email format using shared ValidationHelper
  bool isValidEmail(String email) {
    return ValidationHelper.isValidEmail(email);
  }

  /// Check if email belongs to a staff member (prevent staff signing in as visitors)
  bool isStaffEmail(String email) {
    return _availableContacts.any((contact) =>
      contact.email.toLowerCase() == email.toLowerCase()
    );
  }

  /// Create VisitorData from form fields
  VisitorData? buildVisitorData() {
    if (_currentSite == null) {
      return null;
    }

    return VisitorData(
      fullName: fullNameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      workType: workTypeCtrl.text.trim(),
      company: companyCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      signInTime: signInTimeCtrl.text,
      contactDetailId: _selectedContact?.id ?? '',
      contactDetailName: _selectedContact?.name ?? '',
      contactDetailEmail: _selectedContact?.email ?? '',
      contactDetailPhone: _selectedContact?.phone ?? '',
      siteId: _currentSite!.id,
      notifyPersonVisitingSms: notifyPersonVisitingSms,
      notifyPersonVisitingEmail: notifyPersonVisitingEmail,
      visitorPhotoBytes: _visitorPhotoBytes,
    );
  }

  /// Submit sign-in form
  Future<bool> submitSignIn(BuildContext context) async {
    try {
      _submitting = true;
      _errorMessage = null;
      notifyListeners();

      // Validate required fields
      if (fullNameCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Full name is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (emailCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Email is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (!isValidEmail(emailCtrl.text.trim())) {
        if (context.mounted) context.showError('Invalid email format');
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Check if email belongs to staff
      if (isStaffEmail(emailCtrl.text.trim())) {
        if (context.mounted) {
          context.showError('Staff members cannot sign in as visitors. Please log in from Worx Safety App.');
        }
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Dynamic validation based on field configurations
      if (reqPhone && phoneCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Phone number is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (reqCompany && companyCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Company is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (reqAddress && addressCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Address is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (reqWorkType && workTypeCtrl.text.trim().isEmpty) {
        if (context.mounted) context.showError('Work type is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (reqPersonVisiting && _selectedContact == null) {
        if (context.mounted) context.showError('Please select who you are visiting');
        _submitting = false;
        notifyListeners();
        return false;
      }

      if (reqVisitorPhoto && _visitorPhotoBytes == null) {
        if (context.mounted) context.showError('Visitor photo is required');
        _submitting = false;
        notifyListeners();
        return false;
      }

      // All validations passed - return success
      // Note: API submission will happen in Site Questions page after user answers
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error submitting sign-in: $e');
      if (context.mounted) {
        context.showError('Error submitting sign-in: $e');
      }
      _errorMessage = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    companyCtrl.dispose();
    addressCtrl.dispose();
    workTypeCtrl.dispose();
    signInTimeCtrl.dispose();
    super.dispose();
  }
}

