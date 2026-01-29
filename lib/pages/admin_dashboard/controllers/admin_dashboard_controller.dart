import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/constants/server_link.dart';
import 'package:visitor_practise/core/models/paper_type.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class AdminDashboardController extends ChangeNotifier{

  //----------------------attribute -----------------
  bool _isCheckingInitialDashboard = true;
  bool get isCheckingInitialDashboard => _isCheckingInitialDashboard;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _statusMessage = "";

  bool _wasOnKiosk = false;
  bool get wasOnKiosk => _wasOnKiosk;

  bool _isConnectingPrinter = true;
  bool get isConnectingPrinter => _isConnectingPrinter;

  bool _isInitializedPrinter = true;
  bool get isInitializedPrinter => _isInitializedPrinter;

  bool _showManualInput = true;
  bool get showManualInput => _showManualInput;

  bool _isAddingManualPrinter = true;
  bool get isAddingManualPrinter => _isAddingManualPrinter;

  bool _printModelConnect = true;
  bool get printModelConnect => _printModelConnect;

  // Paper label loading 
  bool _isLoadingPaperType = true;
  bool get isLoadingPaperType => _isLoadingPaperType;

  bool _isPrinting = true;
  bool get isPrinting => _isPrinting;
  
  bool _hasTestPrinted = true;
  bool get hasTestPrinted => _hasTestPrinted;
  

  bool _useCustomBackground = false;
  bool get useCustomBackground => _useCustomBackground;
  String backgroundImage = ServerLink.defaultBackgroup;

  bool _useCustomLogo = false;
  bool get useCustomLogo => _useCustomLogo;
  String logoImageUrl = ServerLink.defaultHeadLogo;
  //-------------------------------------------------require information

  //Site Information
  String? clientDisplayName;

  //Print Information Card
  String printerModel = 'test printer';
  List<PaperType> availablePaperTypes = [];

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

  //Current Site --------------------------------------------------------------data
  Map<String, dynamic>? siteMap;

  // ====== Admin PIN ======
  final TextEditingController adminPinCtrl = TextEditingController();
  bool obscureAdminPin = true;
  bool savingAdminPin = false;
  bool loadingAdminPin = true;
  String adminPin = '1234';
  String? adminPinError;
  String? adminPinStatus;


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

  Future<void> initialise ({
    required Future<void> Function(String nextRoute) onAlreadyRedirect,
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
      siteMap = jsonDecode(savedSelectedSite);
      //debugPrint(savedSelectedSite);
      //{"id":"1","title":"1002567 Thirroul Development - Alternate Loc 1002567 Thirroul Development - Alternate Loc","address":"50 Redman Ave1, THIRROUL, NSW, 25001, Australia","active":true,"site_manager":"","site_supervisor":"{id: 25214, name: Barry Weep Admin}","created_at":"2026-01-29T15:02:05.000638","updated_at":"2026-01-29T15:02:05.000655"}
      // check whether redirect to Kiosk Directly----------
      final alreadyAuthed = await checkExistingAuth();
      if (alreadyAuthed) {
        await onAlreadyRedirect(AppRoutes.visitorKiosk);
        return;
      }
      //-------------------------------------------------end
      final clientJson = await ApiService.fetchVisitorClient(savedToken).timeout(const Duration(seconds: 5));
      //debugPrint(jsonEncode(clientJson));
      //{"logo":"https://storage.worxsafety.com.au/site/public/22080/pblogo.svg","background_image":"https://storage.worxsafety.com.au/site/public/7/60dbb67c245b3_bg-masthead.jpg","slug":"pinkbatteries","name":"HUGH ARTHUR TORNEY","trading_name":"Pink Batteries"}
      await SecureStorageService.saveClient(jsonEncode(clientJson));

      final clientLogo = clientJson['logo'];
      final clientBackgroundImage = clientJson['background_image'];
      final clientTradingName = clientJson['trading_name'];
      final clientName = clientJson['name'];
      final clientSlug = clientJson['slug'];

      if (clientTradingName == null || clientName == null || clientSlug == null) {
        throw Exception('No client essential data collected');
      }
      //for welcome headeer
      clientDisplayName = clientTradingName;

      if (clientLogo != null) {
        _useCustomLogo = true;
        logoImageUrl = clientLogo;
      }

      if (clientBackgroundImage != null) {
        _useCustomBackground = true;
        backgroundImage = clientBackgroundImage;
      }

      //everytime refetch sites
      final sitesJson = await ApiService.fetchVisitorSites(savedToken).timeout(const Duration(seconds: 10));
      //debugPrint(jsonEncode(sitesJson));
      //{"count ":38,"data":[{"id":1,"name":"1002567 Thirroul Development - Alternate Loc 1002567 Thirroul Development - Alternate Loc",
      //"address":"50 Redman Ave1, THIRROUL, NSW, 25001, Australia","streetAddress":"50 Redman Ave1",
      //"suburb":null,"state":"NSW","postcode":"25001","country":"Australia","latitude":-34.27741962,
      //"longitude":150.95425334,"contact":"04057654387","managerName":"Luke One1","customerName":"Test CLIENT1","customerContact":"0400000123",
      //"supervisor":{"id":25214,"name":"Barry Weep Admin"},"createdOn":"2021-08-10T03:59:45+00:00"} ...
      await SecureStorageService.saveSites(jsonEncode(sitesJson));

      final adminSavedPin = await SecureStorageService.getAdminPin().timeout(const Duration(seconds: 10));
      if (adminSavedPin != null && adminSavedPin.isNotEmpty) {
        adminPin = adminSavedPin;
      }
      _isCheckingInitialDashboard = false;
      notifyListeners();

  }

  void startTestPrint() {
    return;
  }
  
  void changePasswordVisibility () {
    //display the password
     obscureAdminPin = !obscureAdminPin;
     notifyListeners();
  }

  void allowPrintBadge(bool v) {
    //display the password
     obscureAdminPin = !obscureAdminPin;
     notifyListeners();
  }

  void onSaveAdminPin() {

  }

  void selectThePaperType(String? v)
  {
    _selectedPaperType = v;
    notifyListeners();
  }

  Future<bool> checkRedirect() async {
    return false;
  }

    Future<bool> checkExistingAuth() async {
    /*
    //check if there is already an Auth Token
    //if last saved location is kiosk dashboard && token, selected site, setting are not empty
    */
    try {
      final lastAccess = await SecureStorageService.getLastAccess().timeout(const Duration(seconds: 50));
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
}