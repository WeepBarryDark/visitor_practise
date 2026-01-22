import 'dart:typed_data';

import 'package:flutter/material.dart';

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

  //TODO
  bool _useCustomBackground = false;
  String? backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String? LogoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  //Site Information Card
  Uint8List? clientLogoBytes;
  String? clientName;


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

  Future<bool> checkRedirect() async {
    return false;
  }

}