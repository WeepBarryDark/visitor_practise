import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/paper_type.dart';

class AdminDashboardController extends ChangeNotifier{
  final Future<void> Function() onConfirmed;

  AdminDashboardController({
    required this.onConfirmed,
  });

  //----------------------attribute -----------------
  bool _isCheckingInitialDashboard = true;
  bool get isCheckingInitialDashboard => _isCheckingInitialDashboard;

  bool _wasOnKiosk = false;
  bool get wasOnKiosk => _wasOnKiosk;

  bool _obscureAdminPin = true;
  bool get obscureAdminPin => _obscureAdminPin;

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
  

  //TODO
  final bool _useCustomBackground = false;
  String? backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String? LogoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  //-------------------------------------------------require information

  //Site Information Card
  Uint8List? clientLogoBytes;
  String? clientName;

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
    required Future<void> Function() onAlreadyRedirect,
  }) async {
    //Get background image 
    backgroundImageUrl = _useCustomBackground
      ? "https://storage.worxsafety.com.au/site/public/7/60dbb67c245b3_bg-masthead.jpg"
      : 'lib/assets/images/worx_inductions_cover.jpg';

    final onRedirect = await checkRedirect();
    if (onRedirect) {
      await onAlreadyRedirect ();
      return;
    }
  }

  void startTestPrint() {
    return;
  }
  
  void changePasswordVisibility () {
    //display the password
     _obscureAdminPin = !_obscureAdminPin;
     notifyListeners();
  }

  void allowPrintBadge(bool v) {
    //display the password
     _obscureAdminPin = !_obscureAdminPin;
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

}