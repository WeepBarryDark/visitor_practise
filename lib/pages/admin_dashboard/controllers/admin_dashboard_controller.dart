import 'dart:async';
import 'dart:convert';

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/core/models/logos_background.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/helper/device_permission.dart';
import 'package:visitor_practise/services/helper/name_beautifier.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/model_service/logos_background_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

enum PrinterStatus { notConnect, startConnect, failedConnect}

class AdminDashboardController extends ChangeNotifier {
  
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;
  //------------------------------------------------attribute
  bool _isCheckingInitialDashboard = true;
  bool get isCheckingInitialDashboard => _isCheckingInitialDashboard;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _statusMessage = "";

  bool _wasOnKiosk = false;
  bool get wasOnKiosk => _wasOnKiosk;

  bool _isInitializingPrinter = true;
  bool get isInitializingdPrinter => _isInitializingPrinter;

  bool _isInitializedPrinter = false;
  bool get isInitializedPrinter => _isInitializedPrinter;

  // Printer connection type: 'model' or 'ip'
  String _printerConnectionType = 'model';
  String get printerConnectionType => _printerConnectionType;

  void setPrinterConnectionType(String type) {
    _printerConnectionType = type;
    notifyListeners();
  }

  bool _isAddingManualPrinter = false;
  bool get isAddingManualPrinter => _isAddingManualPrinter;

  // IP address for manual connection
  final TextEditingController printerIpCtrl = TextEditingController();
  String? printerIpError;

  String printerName = 'Not connected';
  String printerIp = 'N/A';
  bool hasAttemptedConnection = false;

  final String _platformName = 'ios'; //android windows 
  String get platformName => _platformName;


  // Paper label loading 
  bool _isLoadingPaperType = true;
  bool get isLoadingPaperType => _isLoadingPaperType;

  bool _isPrinting = true;
  bool get isPrinting => _isPrinting;
  
  bool _hasTestPrinted = true;
  bool get hasTestPrinted => _hasTestPrinted;
  
  //Site Information
  String? clientDisplayName;
  
  //Current Site ----------------------------------------------------select site data
  late final Map<String, dynamic> currentSiteMap;
  late final SiteItem currentSite;

  //Admin pin----------------------------------------------------------admin pin data
  final TextEditingController adminPinCtrl = TextEditingController();
  bool obscureAdminPin = true;
  bool savingAdminPin = false;
  String adminPin = '1234';
  String? saveAdminPinErrorMessage;

  //-------------------------------------------------print require information

  // BuildContext for permission dialogs (set from dashboard page)

  String printerModel = 'test printer';
  List<PrinterPaperType> availablePaperTypes = [];

  String? _selectedPaperType;
  String? get selectedPaperType => _selectedPaperType;

  //Print Badge
  bool showPreview = false;
  Uint8List? previewImageBytes; // Actual badge image for preview and printing

  //Visitor Information Card-----------------------------------------------------
  bool reqFullName = true;// Always required, cannot be disabled - Text
  bool reqEmail = true; // Always required, cannot be disabled - Text
  bool reqPhone = false;//Text
  bool reqWorkType = false;// Text
  bool reqCompany = false;// Text
  bool reqAddress = false;// Text
  bool reqPersonVisiting = false;//list
  bool reqSignInTime = false;//lock format
  bool reqVisitorPhoto = false;//take a photo
  //Visitor Information Card--------------------------------------------------set function
  void setReqPhone(bool? v) {
    if (v == null) return;
    reqPhone = v;
    notifyListeners();
  }
  void setReqWorkType(bool? v) {
    if (v == null) return;
    reqWorkType = v;
    notifyListeners();
  }
  void setReqCompany(bool? v) {
    if (v == null) return;
    reqCompany = v;
    notifyListeners();
  }
  void setReqAddress(bool? v) {
    if (v == null) return;
    reqAddress = v;
    notifyListeners();
  }
  void setReqPersonVisiting(bool? v) {
    if (v == null) return;
    reqPersonVisiting = v;
    notifyListeners();
  }
  void setReqSignTime(bool? v) {
    if (v == null) return;
    reqSignInTime = v;
    notifyListeners();
  }
  void setReqVisitorPhoto(bool? v) {
    if (v == null) return;
    reqVisitorPhoto = v;
    notifyListeners();
  }
  //print required---------------------------------------------------------------
  bool reqPrint = true;//enable print
  void setReqPrint(bool? v, {BuildContext? context}) { // ----set function
    if (v == null) return;
    reqPrint = v;
    notifyListeners();
    if (v && context != null) {
      initializePrinter(context);
    }
  }
  //Notification Setting-----------------------------------------------------
  bool notifyDeliverySms = false;
  bool notifyDeliveryEmail = false;
  bool notifyPersonVisitingSms = false;
  bool notifyPersonVisitingEmail = false;
  
  void setNotifyDeliverySms(bool? v) {
    if (v == null) return;
    notifyDeliverySms = v;
    notifyListeners();
  }
  void setNotifyDeliveryEmail(bool? v) {
    if (v == null) return;
    notifyDeliveryEmail = v;
    notifyListeners();
  }
  void setNotifyPersonVisitingSms(bool? v) {
    if (v == null) return;
    notifyPersonVisitingSms = v;
    notifyListeners();
  }
  void setNotifyPersonVisitorEmail(bool? v) {
    if (v == null) return;
    notifyPersonVisitingEmail = v;
    notifyListeners();
  }
  //Notification Setting-----------------------------------------------------
  bool enableVisitorSignIn = true;
  bool enableVisitorSignOut = true;
  bool enableVisitorDelivery = false;
  bool enableContractorSignIn = false;
  bool enableVisitorRetrieveBadge = false;

  void setEnableVisitorDelivery(bool? v) {
    if (v == null) return;
    enableVisitorDelivery = v;
    notifyListeners();
  }
  void setEnableContractorSignIn(bool? v) {
    if (v == null) return;
    enableContractorSignIn = v;
    notifyListeners();
  }
  void setEnableVisitorRetrieveBadge(bool? v) {
    if (v == null) return;
    enableVisitorRetrieveBadge = v;
    notifyListeners();
  }
  // initialization-----------------------------------------------
  Future<void> initialise ({
    required Future<void> Function(String nextRoute) onAlreadyRedirect,
    BuildContext? context,
  }) async {
      final savedToken = await  SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (savedToken == null || savedToken.isEmpty) {
         throw Exception('No token');
      }
      //if no select -> Jump to site select page  
      final savedSelectedSite = await  SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite == null || savedSelectedSite.isEmpty) {
        await onAlreadyRedirect(AppRoutes.newSite);
        return;
      }
      currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
      //debugPrint(jsonEncode(currentSiteMap));
      currentSite = SiteItem.fromJson(currentSiteMap);
      //debugPrint(jsonEncode(currentSite));
      //debugPrint(savedSelectedSite);
      //{"id":"1","title":"1002567 Thirroul Development - Alternate Loc 1002567 Thirroul Development - Alternate Loc","address":"50 Redman Ave1, THIRROUL, NSW, 25001, Australia","active":true,"site_manager":"","site_supervisor":"{id: 25214, name: Barry Weep Admin}","created_at":"2026-01-29T15:02:05.000638","updated_at":"2026-01-29T15:02:05.000655"}
      // check whether redirect to Kiosk Directly----------
      final alreadyAuthed = await checkExistingAuth();
      if (alreadyAuthed) {
        await onAlreadyRedirect(AppRoutes.kioskDashboard);
        return;
      }
      //-------------------------------------------------end
      final clientJson = await ApiService.fetchVisitorClient(savedToken).timeout(const Duration(seconds: 5));
      //debugPrint(jsonEncode(clientJson));
      //{"logo":"https://storage.worxsafety.com.au/site/public/22080/pblogo.svg","background_image":"https://storage.worxsafety.com.au/site/public/7/60dbb67c245b3_bg-masthead.jpg","slug":"pinkbatteries","name":"HUGH ARTHUR TORNEY","trading_name":"Pink Batteries"}
      await SecureStorageService.saveClient(jsonEncode(clientJson));

      final clientLogo = clientJson['logo'] as String?;
      final clientBackgroundImage = clientJson['background_image'] as String?;
      final clientTradingName = clientJson['trading_name'];
      final clientName = clientJson['name'];
      final clientSlug = clientJson['slug'];

      if (clientTradingName == null || clientName == null || clientSlug == null) {
        throw Exception('No client essential data collected');
      }
      //for welcome headeer
      clientDisplayName = clientTradingName;
      final logoService = LogosBackgroundService();
      logoService.create(customTopLogUrl: clientLogo, customBackground: clientBackgroundImage);

      // Load client logo bytes from SecureStorage or use default
      topLogo = await SecureStorageService.getClientTopLogoBytes();
      bottomLogo = await SecureStorageService.getClientBottomLogoBytes();
      background = await SecureStorageService.getClientBackgroundBytes();

      //everytime refetch sites
      final sitesJson = await ApiService.fetchVisitorSites(savedToken).timeout(const Duration(seconds: 10));
      //debugPrint(jsonEncode(sitesJson));
      //{"count ":38,"data":[{"id":1,"name":"1002567 Thirroul Development - Alternate Loc 1002567 Thirroul Development - Alternate Loc",
      //"address":"50 Redman Ave1, THIRROUL, NSW, 25001, Australia","streetAddress":"50 Redman Ave1",
      //"suburb":null,"state":"NSW","postcode":"25001","country":"Australia","latitude":-34.27741962,
      //"longitude":150.95425334,"contact":"04057654387","managerName":"Luke One1","customerName":"Test CLIENT1","customerContact":"0400000123",
      //"supervisor":{"id":25214,"name":"Barry Weep Admin"},"createdOn":"2021-08-10T03:59:45+00:00"} ...
      await SecureStorageService.saveSites(jsonEncode(sitesJson));

      //loading the admin pin
      final adminSavedPin = await SecureStorageService.getAdminPin().timeout(const Duration(seconds: 10));
      if (adminSavedPin != null && adminSavedPin.isNotEmpty) {
        adminPin = adminSavedPin;
      }
      adminPinCtrl.text = adminPin;
      await _loadVisitorRequirements();
      _isCheckingInitialDashboard = false;
      notifyListeners();

      // Auto-initialize printer if enabled
      if (reqPrint && context != null && context.mounted) {
        initializePrinter(context);
      }
  }

  Future<bool> checkExistingAuth() async {
    /*
    //check if there is already an Auth Token
    //if last saved location is kiosk dashboard && token, selected site, setting are not empty
    */
    try {
      final lastAccess = await SecureStorageService.getLastKioskAccess().timeout(const Duration(seconds: 50));
      if (lastAccess == 'kiosk_dashboard')
      {
        //TODO
        final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 50));
        final alreadyAuthed = token != null && token.isNotEmpty;

        _hasError = false;
        notifyListeners();

        return alreadyAuthed; // return true -> jump to kiosk dashboard
      }
      return false;
    } on TimeoutException {
      // not sure what to do now, when an error and timeout
      _hasError = true;
      _statusMessage = 'Request timed out. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      // not sure what to do now, when an error and timeout
      _hasError = true;
      _statusMessage = 'Error while checking existing login. Please start a new session.';
      notifyListeners();
      return false;
    }
  }

  //-----------------------------------------------admin pin section
  void changePasswordVisibility () {
    //display the password
     obscureAdminPin = !obscureAdminPin;
     notifyListeners();
  }

  Future<void> onSaveAdminPin() async {

    savingAdminPin = true;
    saveAdminPinErrorMessage = null;
    final pin = adminPinCtrl.text.trim();
    if (pin.length < 4) {
      saveAdminPinErrorMessage = 'Password must be at least 4 characters.';
      notifyListeners();
      return;
    }

    try {
      await SecureStorageService.saveAdminPin(pin);
      adminPin = pin;
    } catch (e) {
      saveAdminPinErrorMessage = 'Save failed: $e';
      debugPrint('Error saving admin pin: $e');
    } finally {
      savingAdminPin = false;
      notifyListeners();
    }
  }
  

//------------------------------------------print section

//Print Information Card - All Brother printer models from another_brother package
static List<brother.Model> get supportedPrinterModels {
  // Filter out UNSUPPORTED model
  return brother.Model.getValues()
      .where((m) => m.getName() != 'UNSUPPORTED')
      .toList();
}

brother.Model? _selectedPrinterModel;
brother.Model? get selectedPrinterModel => _selectedPrinterModel;

void selectPrinterModel(brother.Model? model) {
  _selectedPrinterModel = model;
  // Update available paper types based on selected model
  if (model != null) {
    availablePaperTypes = PrinterPaperType.getPrinterPaperTypesForModel(model.getName());
    // Reset paper type selection if current selection is not compatible
    if (_selectedPaperType != null) {
      final isCompatible = availablePaperTypes.any((p) => p.code == _selectedPaperType);
      if (!isCompatible) {
        _selectedPaperType = null;
      }
    }
  } else {
    availablePaperTypes = [];
    _selectedPaperType = null;
  }
  notifyListeners();
}


Future<void> initializePrinter(BuildContext context) async {
  if (_isInitializingPrinter) {
    debugPrint('Printer already initializing, skipping...');
    return;
  }
  _isInitializingPrinter = true;
  notifyListeners();
  try {
    // Request permissions (with dialogs to guide user)
    final hasPermission = await DevicePermission.requestPrinterPermissions(context,);

    if (!hasPermission) {
      printerName = 'Permission denied';
      printerIp = 'Grant permissions to discover printers';
      hasAttemptedConnection = true;
      _isInitializedPrinter = false;
      return;
    }

    // Check if there's a saved printer to try reconnecting to
    final savedPrinter = await SecureStorageService.getLastPrinter();

    if (savedPrinter != null) {
      // STEP 1: Try to reconnect to saved printer (fast)
      printerName = 'Reconnecting to printer...';
      printerIp = 'Checking saved printer';
      notifyListeners();

      //final reconnected = await BadgePrinter.tryConnectToSavedPrinter();
    }

    // TODO: Add your printer initialization logic here
    // For example:
    // final printers = await discoverPrinters();
    // if (printers.isNotEmpty) {
    //   printerName = printers.first.name;
    //   printerIp = printers.first.ipAddress;
    //   _isInitializedPrinter = true;
    // }

    debugPrint('Printer initialization completed');
    hasAttemptedConnection = true;

  } catch (e) {
    debugPrint('Printer initialization failed: $e');
    printerName = 'Initialization failed';
    printerIp = 'Error: $e';
    _isInitializedPrinter = false;
    hasAttemptedConnection = true;
  } finally {
    _isInitializingPrinter = false;
    notifyListeners();
  }
}

void startTestPrint() {
  return;
}

void selectThePaperType(String? v)
{
  _selectedPaperType = v;
  notifyListeners();
}

//--------------------------------------------------------required visitor information field section

  Future<void> _loadVisitorRequirements() async {
    final requirementsJson = await SecureStorageService.getAdminDashboardSettings();
    if (requirementsJson != null && requirementsJson.isNotEmpty) {
      final data = jsonDecode(requirementsJson) as Map<String, dynamic>;
      reqFullName = true;// Always required, cannot be disabled - Text
      reqEmail = true; 
      reqPhone = data['req_phone'] as bool? ?? false;
      reqWorkType = data['req_work_type'] as bool? ?? false;
      reqCompany = data['req_company'] as bool? ?? false;
      reqAddress = data['req_address'] as bool? ?? false;
      reqPersonVisiting = data['req_person_visiting'] as bool? ?? false;
      reqSignInTime = data['req_sign_in_time'] as bool? ?? false;
      reqVisitorPhoto = data['req_visitor_photo'] as bool? ?? false;
      reqPrint = data['req_print'] as bool? ?? false;
      notifyDeliverySms = data['notify_delievery_sms'] as bool? ?? false;
      notifyDeliveryEmail = data['notify_delievery_email'] as bool? ?? false;
      notifyPersonVisitingSms = data['notify_person_visiting_sms'] as bool? ?? false;
      notifyPersonVisitingEmail = data['notify_person_visiting_email'] as bool? ?? false;
      enableVisitorSignIn = true;
      enableVisitorSignOut = true;
      enableVisitorDelivery = data['enable_visitor_delivery'] as bool? ?? false;
      enableContractorSignIn = data['enable_contractor_sign_in'] as bool? ?? false;
      enableVisitorRetrieveBadge = data['enable_visitor_retrieve_badge'] as bool? ?? false;
    }
  }

  Future<void> _saveVisitorRequirements() async {
    final requirements = {
      'req_full_name': reqFullName,
      'req_email': reqEmail,
      'req_phone': reqPhone,
      'req_work_type': reqWorkType,
      'req_company': reqCompany,
      'req_address': reqAddress,
      'req_person_visiting': reqPersonVisiting,
      'req_sign_in_time': reqSignInTime,
      'req_visitor_photo': reqVisitorPhoto,
      'req_print': reqPrint,
      'notify_delievery_sms': notifyDeliverySms,
      'notify_delievery_email': notifyDeliveryEmail,
      'notify_person_visiting_sms': notifyPersonVisitingSms,
      'notify_person_visiting_email': notifyPersonVisitingEmail,
      'enable_visitor_sign_in' : enableVisitorSignIn,
      'enable_visitor_sign_out' : enableVisitorSignOut,
      'enable_visitor_delivery' : enableVisitorDelivery,
      'enable_contractor_sign_in' : enableContractorSignIn,
      'enable_visitor_retrieve_badge' : enableVisitorRetrieveBadge,
    };
    await SecureStorageService.saveAdminDashboardSettings(jsonEncode(requirements));
  }

  Future<void> generatePreview() async {
    const uuid = Uuid();
    final sampleVisitorId = uuid.v4().substring(0, 8).toUpperCase(); // Short ID for demo

    final timezoneSnapshot = reqSignInTime ? DateTime.now() : null;
    final badgeData = BadgeGenerator(
      visitorId: sampleVisitorId,
      fullName: reqFullName ? 'Firstname Lastname' : null,
      email: reqEmail ? 'visitor@example.com' : null,
      phone: reqPhone ? '+61 412 345 678' : null,
      workType: reqWorkType ? 'Contractor' : null,
      company: reqCompany ? 'ABC Construction' : null,
      address: reqAddress ? '123 Main St, Sydney' : null,
      supervisor: reqPersonVisiting ? 'Barry Wang' : null,
      signInTime: timezoneSnapshot == null ? null : DateTime.now().toIso8601String(),
      siteName: resolveSiteHeading(currentSite,'Visitor Badge'),
      clientLogoBytes: topLogo, // Use client logo bytes if available
      visitorPhotoBytes: reqVisitorPhoto ? Uint8List(1) : null, // Dummy photo data for preview
    );

    // Generate the actual image (same one that will be printed)
    previewImageBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);
    showPreview = true;
    notifyListeners();
  }
  
  //------------------------------------------------------------------confirm and go to Kiosk
  Future<void> confirmToKiosk() async {
     await _saveVisitorRequirements();
  }

  @override
  void dispose() {
    adminPinCtrl.dispose();
    printerIpCtrl.dispose();
    super.dispose();
  }

}
