import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/core/models/printer_discover.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/helper/device_permission.dart';
import 'package:visitor_practise/services/helper/name_beautifier.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/model_service/logos_background_service.dart';
import 'package:visitor_practise/services/model_service/printer_discover_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/timezone_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

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

  final bool _wasOnKiosk = false;
  bool get wasOnKiosk => _wasOnKiosk;

  bool _isInitializingPrinter = false;
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
  String printerIp = 'Click Connect to setup printer';
  bool hasAttemptedConnection = false;

  final String _platformName = 'ios'; //android windows 
  String get platformName => _platformName;


  // Connected printer
  PrinterDiscover? _connectedPrinter;
  PrinterDiscover? get connectedPrinter => _connectedPrinter;

  // Paper label loading
  bool _isLoadingPaperType = false;
  bool get isLoadingPaperType => _isLoadingPaperType;

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

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
    if (!reqPersonVisiting) {
      notifyPersonVisitingSms = false;
      notifyPersonVisitingEmail = false;
    }
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
    // Don't auto-initialize - user must click Connect button
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
  bool enableContractorSignOut = false;
  bool enableVisitorRetrieveBadge = false;

  //Screen Size Control-----------------------------------------------------
  String _screenSize = 'medium'; // compact, medium, large
  String get screenSize => _screenSize;

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
  void setEnableContractorSignOut(bool? v) {
    if (v == null) return;
    enableContractorSignOut = v;
    notifyListeners();
  }
  void setEnableVisitorRetrieveBadge(bool? v) {
    if (v == null) return;
    enableVisitorRetrieveBadge = v;
    notifyListeners();
  }

  Future<void> updateScreenSize(String size) async {
    if (size != 'compact' && size != 'medium' && size != 'large') {
      debugPrint('Invalid screen size: $size, defaulting to medium');
      _screenSize = 'medium';
    } else {
      _screenSize = size;
    }
    notifyListeners();
    // Save to storage immediately
    await _saveVisitorRequirements();
    debugPrint('Screen size updated and saved: $_screenSize');
  }
  // initialization-----------------------------------------------
  Future<void> initialise ({
    required Future<void> Function(String nextRoute) onAlreadyRedirect,
    BuildContext? context,
  }) async {
      final savedToken = await  SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (savedToken == null || savedToken.isEmpty) {
        // Show error BEFORE navigation
        if (context != null && context.mounted) {
          context.showError('Token issue, please sign in again');
          await Future.delayed(const Duration(milliseconds: 800));
        }
        await onAlreadyRedirect(AppRoutes.auth);
        return;
      }
      //if no select -> Jump to site select page
      final savedSelectedSite = await  SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite == null || savedSelectedSite.isEmpty) {
        // Show error BEFORE navigation
        if (context != null && context.mounted) {
          context.showError('Selected site issue, please reselect site');
          await Future.delayed(const Duration(milliseconds: 800));
        }
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

      //------------------------------------------------
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
      await _loadSavedPrinterAndPaperType();
      _isCheckingInitialDashboard = false;
      notifyListeners();

      // Don't auto-initialize printer - user must click Connect button
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
        _hasError = false;
        notifyListeners();

        return true; // return true -> jump to kiosk dashboard
      }
      return false;
    } on TimeoutException {
      // not sure what to do now, when an error and timeout
      _hasError = true;
      notifyListeners();
      return false;
    } catch (e) {
      // not sure what to do now, when an error and timeout
      _hasError = true;
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

//Print Information Card - Only support QL, PT, TD, RJ series Brother printers
static List<brother.Model> get supportedPrinterModels {
  return brother.Model.getValues()
      .where((m) {
        final name = m.getName().toUpperCase();
        // Only include QL, PT, TD, RJ series, exclude UNSUPPORTED
        return (name.startsWith('QL-') ||
                name.startsWith('PT-') ||
                name.startsWith('TD-') ||
                name.startsWith('RJ-')) &&
               name != 'UNSUPPORTED';
      })
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

Future<void> connectToThePrint() async {
  // Only clear paper type if switching to a different printer model
  // Check if we're connecting to a different model than what's currently connected
  final isDifferentPrinter = _connectedPrinter == null ||
      (_selectedPrinterModel != null &&
       _connectedPrinter!.printerModel != _selectedPrinterModel!.getName());

  if (isDifferentPrinter) {
    // Clear paper type selection when connecting to a different printer
    _selectedPaperType = null;
    await SecureStorageService.clearPaperType();
    debugPrint('Switching to different printer - cleared paper type');
  } else {
    // Reconnecting to same printer - keep paper type
    debugPrint('Reconnecting to same printer - keeping paper type');
  }

  if (_printerConnectionType == 'model') {
    // Connect by model - discover printers on network
    final model = _selectedPrinterModel;

    if (model == null) {
      printerName = 'No model selected';
      printerIp = 'Please select a printer model';
      notifyListeners();
      return;
    }

    try {
      _isInitializingPrinter = true;
      printerName = 'Searching for printers...';
      printerIp = 'Scanning network...';
      _isInitializedPrinter = false;
      notifyListeners();

      // Discover printers using the selected model
      final printers = await PrinterDiscoverService.getNetPrinters(model);

      if (printers.isEmpty) {
        printerName = 'No printers found';
        printerIp = 'No ${model.getName()} printers on network';
        _isInitializedPrinter = false;
        _connectedPrinter = null;
      } else {
        // Use the first discovered printer
        final printer = printers.first;
        _connectedPrinter = printer;
        printerName = printer.printerName;
        printerIp = printer.printerAddress;
        _isInitializedPrinter = true;

        debugPrint('Connected to printer: $printerName at $printerIp');

        // Save printer info to local storage on successful connection
        await SecureStorageService.saveLastPrinter(
          name: printer.printerName,
          address: printer.printerAddress,
          model: printer.printerModel,
        );
        debugPrint('Printer info saved to local storage');

        // Auto-load paper types from printer
        await _loadPaperTypesFromPrinter(printer);
      }
    } catch (e) {
      printerName = 'Connection failed';
      printerIp = 'Error: $e';
      _isInitializedPrinter = false;
      _connectedPrinter = null;
      debugPrint('Failed to discover printers: $e');
    } finally {
      _isInitializingPrinter = false;
      notifyListeners();
    }
  } else if (_printerConnectionType == 'ip') {
    // Connect by IP address
    final ipAddress = printerIpCtrl.text.trim();
    final model = _selectedPrinterModel;

    if (ipAddress.isEmpty) {
      printerIpError = 'Please enter an IP address';
      notifyListeners();
      return;
    }

    if (model == null) {
      printerIpError = 'Please select a printer model';
      notifyListeners();
      return;
    }

    // Check if connecting to different IP address
    final isDifferentIp = _connectedPrinter == null ||
        _connectedPrinter!.printerAddress != ipAddress;

    if (isDifferentIp && _selectedPaperType != null) {
      // Clear paper type if switching to different IP
      _selectedPaperType = null;
      await SecureStorageService.clearPaperType();
      debugPrint('Switching to different IP - cleared paper type');
    }

    try {
      _isInitializingPrinter = true;
      _isAddingManualPrinter = true;
      printerName = 'Connecting to printer...';
      printerIp = 'Connecting to $ipAddress...';
      printerIpError = null;
      _isInitializedPrinter = false;
      notifyListeners();

      // Connect to printer by IP
      final printer = await PrinterDiscoverService.connectByIp(
        ipAddress: ipAddress,
        model: model,
      );

      if (printer != null) {
        _connectedPrinter = printer;
        printerName = printer.printerName;
        printerIp = printer.printerAddress;
        _isInitializedPrinter = true;
        printerIpError = null;

        debugPrint('Connected to printer: $printerName at $printerIp');

        // Auto-load paper types from printer
        await _loadPaperTypesFromPrinter(printer);
      } else {
        printerName = 'Connection failed';
        printerIp = 'Could not connect to $ipAddress';
        printerIpError = 'Invalid IP or printer not reachable';
        _isInitializedPrinter = false;
        _connectedPrinter = null;
      }
    } catch (e) {
      printerName = 'Connection failed';
      printerIp = 'Error: $e';
      printerIpError = e.toString();
      _isInitializedPrinter = false;
      _connectedPrinter = null;
      debugPrint('❌ Failed to connect by IP: $e');
    } finally {
      _isInitializingPrinter = false;
      _isAddingManualPrinter = false;
      notifyListeners();
    }
  } else if (_printerConnectionType == 'usb') {
    // Connect by USB
    /*
    final model = _selectedPrinterModel;

    if (model == null) {
      printerName = 'No model selected';
      printerIp = 'Please select a printer model';
      notifyListeners();
      return;
    }

    try {
      _isInitializingPrinter = true;
      printerName = 'Connecting to USB printer...';
      printerIp = 'Establishing USB connection...';
      _isInitializedPrinter = false;
      notifyListeners();

      // Connect to printer by USB
      final printer = await PrinterDiscoverService.connectByUsb(
        model: model,
      );

      if (printer != null) {
        _connectedPrinter = printer;
        printerName = printer.printerName;
        printerIp = 'USB Connected';
        _isInitializedPrinter = true;

        debugPrint('Connected to printer via USB: $printerName');

        // Auto-load paper types from printer
        await _loadPaperTypesFromPrinter(printer);
      } else {
        printerName = 'Connection failed';
        printerIp = 'Could not connect via USB';
        _isInitializedPrinter = false;
        _connectedPrinter = null;
      }
    } catch (e) {
      printerName = 'Connection failed';
      printerIp = 'Error: $e';
      _isInitializedPrinter = false;
      _connectedPrinter = null;
      debugPrint(' Failed to connect by USB: $e');
    } finally {
      _isInitializingPrinter = false;
      notifyListeners();
    }
    */
  }

  hasAttemptedConnection = true;
}

/// Auto-load paper types from printer using getLabelInfo
Future<void> _loadPaperTypesFromPrinter(PrinterDiscover printerDiscover) async {
  try {
    _isLoadingPaperType = true;
    notifyListeners();

    debugPrint('Loading paper types for model: ${printerDiscover.printerModel}');

    // First, always load available paper types based on model
    availablePaperTypes = PrinterPaperType.getPrinterPaperTypesForModel(
      printerDiscover.printerModel,
    );

    debugPrint('Found ${availablePaperTypes.length} paper types for ${printerDiscover.printerModel}');

    // Try to get label info from printer to auto-select current paper
    final printerInfo = printerDiscover.printerInfo;
    if (printerInfo != null) {
      try {
        final printer = brother.Printer();
        /// Print the image file or print data file (.prn) using print settings set by
        await printer.setPrinterInfo(printerInfo);
        final labelInfo = await printer.getLabelInfo();

        debugPrint('Label Info from printer:');
        debugPrint('labelNameIndex: ${labelInfo.labelNameIndex}');
        debugPrint('labelColor: ${labelInfo.labelColor}');
        debugPrint('isSpecialTape: ${labelInfo.isSpecialTape}');

        // Try to get printer status (might contain paper info)
        try {
          final printerStatus = await printer.getPrinterStatus();
          debugPrint('Printer Status:');
          debugPrint('errorCode: ${printerStatus.errorCode}');
          debugPrint('status: $printerStatus');
        } catch (statusError) {
          debugPrint('getPrinterStatus failed: $statusError');
        }

        // Try to get printer settings
        try {
          final Map<brother.PrinterSettingItem, String> settingsOut = {};
          final List<brother.PrinterSettingItem> settingsToQuery = [
            brother.PrinterSettingItem.PRINT_DENSITY,
            brother.PrinterSettingItem.PRINT_SPEED,
            brother.PrinterSettingItem.NET_STATIC_IPV4ADDRESS,
            brother.PrinterSettingItem.NET_NODENAME,
          ];

          final settingsStatus = await printer.getPrinterSettings(
            settingsToQuery,
            settingsOut,
          );

          if (settingsStatus.errorCode == brother.ErrorCode.ERROR_NONE) {
            debugPrint('Printer Settings:');
            settingsOut.forEach((key, value) {
              debugPrint('${key.getName()}: $value');
            });
          } else {
            debugPrint('getPrinterSettings error: ${settingsStatus.errorCode.getName()}');
          }
        } catch (settingsError) {
          debugPrint('getPrinterSettings failed: $settingsError');
        }

        // Try to auto-select paper type based on labelNameIndex
        if (labelInfo.labelNameIndex >= 0) {
          final matchingPaper = PrinterPaperType.fromLabelNameIndex(
            labelInfo.labelNameIndex,
          );
          if (matchingPaper != null) {
            _selectedPaperType = matchingPaper.code;
            debugPrint('Auto-selected paper type: ${matchingPaper.code}');
          } else {
            debugPrint('No matching paper type found for labelNameIndex: ${labelInfo.labelNameIndex}');
          }
        } else {
          debugPrint('Printer cannot detect paper type (labelNameIndex: ${labelInfo.labelNameIndex})');
          debugPrint('Please manually select the paper type installed in your printer');
        }
      } catch (labelError) {
        debugPrint('Could not get label info from printer: $labelError');
        debugPrint('Paper types still loaded from model');
      }
    }

    _isLoadingPaperType = false;
    notifyListeners();

    debugPrint('Paper types ready: ${availablePaperTypes.length} options available');
  } catch (e, stackTrace) {
    debugPrint('Failed to load paper types: $e');
    debugPrint('Stack trace: $stackTrace');

    // Last resort fallback
    availablePaperTypes = PrinterPaperType.getPrinterPaperTypesForModel(printerDiscover.printerModel,);

    _isLoadingPaperType = false;
    notifyListeners();

    debugPrint('Loaded ${availablePaperTypes.length} paper types as fallback');
  }
}

Future<void> startTestPrint(BuildContext context) async {
  if (!_isInitializedPrinter || _connectedPrinter == null) {
    if (context.mounted) {
      context.showError('No printer connected');
    }
    return;
  }

  if (_selectedPaperType == null) {
    if (context.mounted) {
      context.showError('Please select a paper type first');
    }
    return;
  }

  if (_isPrinting) {
    if (context.mounted) {
      context.showWarning('Already printing, please wait...');
    }
    return;
  }

  try {
    _isPrinting = true;
    notifyListeners();

    final printerInfo = _connectedPrinter!.printerInfo;
    if (printerInfo == null) {
      throw Exception('Printer info not available');
    }

    // Find the selected paper type details
    final paperType = PrinterPaperType.fromCode(_selectedPaperType!);
    if (paperType == null) {
      throw Exception('Invalid paper type: $_selectedPaperType');
    }

    // Set label name index based on paper type
    printerInfo.labelNameIndex = paperType.labelNameIndex;

    // Generate simple test image
    final testImage = await _generateTestImage();

    // Print the test image
    final printer = brother.Printer();
    await printer.setPrinterInfo(printerInfo);

    final printResult = await printer.printImage(testImage);

    if (printResult.errorCode == brother.ErrorCode.ERROR_NONE) {
      // Save printer info to local storage on successful print
      await SecureStorageService.saveLastPrinter(
        name: _connectedPrinter!.printerName,
        address: _connectedPrinter!.printerAddress,
        model: _connectedPrinter!.printerModel,
      );

      // Save paper type to local storage on successful print
      await SecureStorageService.savePaperType(paperType.toJson());

      if (context.mounted) {
        context.showSuccess('Test print completed successfully!');
      }
    } else if (printResult.errorCode == brother.ErrorCode.ERROR_WRONG_LABEL) {
      if (context.mounted) {
        context.showError('Wrong paper type. Check if ${paperType.code} is installed');
      }
    } else {
      if (context.mounted) {
        context.showError('Print failed: ${printResult.errorCode.getName()}');
      }
    }
  } catch (e, stackTrace) {
    debugPrint('Print error: $e');
    debugPrint('Stack trace: $stackTrace');
    if (context.mounted) {
      context.showError('Print failed: $e');
    }
  } finally {
    _isPrinting = false;
    notifyListeners();
  }
}

void selectThePaperType(String? v) {
  _selectedPaperType = v;
  notifyListeners();
}

/// Generate simple test image with text
Future<ui.Image> _generateTestImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 200));

  // White background
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 400, 200),
    Paint()..color = Colors.white,
  );

  // Draw text "print tested"
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'print tested',
      style: TextStyle(
        color: Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (400 - textPainter.width) / 2,
      (200 - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(400, 200);

  return image;
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
      enableContractorSignOut = data['enable_contractor_sign_out'] as bool? ?? false;
      enableVisitorRetrieveBadge = data['enable_visitor_retrieve_badge'] as bool? ?? false;
      _screenSize = data['screen_size'] as String? ?? 'medium';
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
      'enable_contractor_sign_out' : enableContractorSignOut,
      'enable_visitor_retrieve_badge' : enableVisitorRetrieveBadge,
      'screen_size': _screenSize,
    };
    await SecureStorageService.saveAdminDashboardSettings(jsonEncode(requirements));
  }

  /// Load saved printer and paper type from local storage
  Future<void> _loadSavedPrinterAndPaperType() async {
    try {
      // Load saved printer
      final printerData = await SecureStorageService.getLastPrinter();
      if (printerData != null) {
        final savedModel = printerData['model'] as String? ?? '';

        // Find the model
        final model = brother.Model.getValues().firstWhere(
          (m) => m.getName() == savedModel,
          orElse: () => brother.Model.UNSUPPORTED,
        );

        if (model != brother.Model.UNSUPPORTED) {
          _selectedPrinterModel = model;

          final savedAddress = printerData['address'] as String? ?? 'N/A';

          // Create printer info
          final printerInfo = brother.PrinterInfo()
            ..printerModel = model
            ..port = savedAddress == 'USB' ? brother.Port.USB : brother.Port.NET
            ..ipAddress = savedAddress != 'USB' ? savedAddress : '';

          // Create PrinterDiscover object from JSON
          _connectedPrinter = PrinterDiscover.fromJson(
            printerData,
            printerInfo: printerInfo,
          );

          // Set display values
          printerName = _connectedPrinter!.printerName;
          printerIp = _connectedPrinter!.printerAddress;

          // Load available paper types for this model
          availablePaperTypes = PrinterPaperType.getPrinterPaperTypesForModel(savedModel);

          // Mark as initialized (connected)
          _isInitializedPrinter = true;
          hasAttemptedConnection = true;

          debugPrint('Loaded saved printer: ${_connectedPrinter!.printerName} at ${_connectedPrinter!.printerAddress}');
          debugPrint('Available paper types: ${availablePaperTypes.length}');
        } else {
          debugPrint('Saved printer model not supported: $savedModel');
        }
      }

      // Load saved paper type
      final paperTypeData = await SecureStorageService.getPaperType();
      if (paperTypeData != null) {
        final paperType = PrinterPaperType.fromJson(paperTypeData);
        _selectedPaperType = paperType.code;
        debugPrint('Loaded saved paper type: ${paperType.code}');
        debugPrint('Ready to print - all settings restored!');
      }
    } catch (e) {
      debugPrint('Failed to load saved printer/paper type: $e');
    }
  }

  Future<void> generatePreview() async {
    const uuid = Uuid();
    final sampleVisitorId = uuid.v4().substring(0, 8).toUpperCase(); // Short ID for demo

    // Use TimezoneService for formatted time
    final formattedTime = reqSignInTime
        ? TimezoneService.formatLocal(TimezoneService.captureNow().localTime)
        : null;

    final badgeData = BadgeGenerator(
      visitorId: sampleVisitorId,
      fullName: reqFullName ? 'Firstname Lastname' : null,
      email: reqEmail ? 'visitor@example.com' : null,
      phone: reqPhone ? '+61 412 345 678' : null,
      workType: reqWorkType ? 'Contractor' : null,
      company: reqCompany ? 'ABC Construction' : null,
      address: reqAddress ? '123 Main St, Sydney' : null,
      supervisor: reqPersonVisiting ? 'Barry Wang' : null,
      signInTime: formattedTime,
      siteName: resolveSiteHeading(currentSite,'Visitor Badge'),
      clientLogoBytes: topLogo,
      visitorPhotoBytes: reqVisitorPhoto ? Uint8List(1) : null,
      // Field configurations - only show required fields
      showFullName: reqFullName,
      showEmail: reqEmail,
      showPhone: reqPhone,
      showWorkType: reqWorkType,
      showCompany: reqCompany,
      showAddress: reqAddress,
      showSupervisor: reqPersonVisiting,
      showSignInTime: reqSignInTime,
      showVisitorPhoto: reqVisitorPhoto,
    );

    // Generate the actual image (same one that will be printed)
    previewImageBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);
    showPreview = true;
    notifyListeners();
  }
  
  //------------------------------------------------------------------confirm and go to Kiosk
  Future<bool> confirmToKiosk(BuildContext context) async {
     if(reqPrint && _connectedPrinter == null) {
        context.showError('Printing Badge is required, but no printer connect. Please connect to printer');
        return false;
     } else {
        context.showSuccess('Configurations saved. Starting kiosk mode');
        await _saveVisitorRequirements();
        return true;
     }
  }

  @override
  void dispose() {
    adminPinCtrl.dispose();
    printerIpCtrl.dispose();
    super.dispose();
  }

}
