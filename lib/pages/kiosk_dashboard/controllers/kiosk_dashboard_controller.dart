import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskDashboardController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  //----------------------------------------------------
  bool _enableVisitorSignIn = true;
  bool get enableVisitorSignIn => _enableVisitorSignIn;

  bool _enableVisitorSignOut = true;
  bool get enableVisitorSignOut => _enableVisitorSignOut;

  bool _enableVisitorDelivery = false;
  bool get enableVisitorDelivery => _enableVisitorDelivery;

  bool _enableContractorSignIn = false;
  bool get enableContractorSignIn => _enableContractorSignIn;

  bool _enableVisitorRetrieveBadge = false;
  bool get enableVisitorRetrieveBadge => _enableVisitorRetrieveBadge;

  bool _enableContractorSignOut = false;
  bool get enableContractorSignOut => _enableContractorSignOut;

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial; 

  Future<void> initializing () async {
    topLogo = await SecureStorageService.getClientTopLogoBytes();
    bottomLogo = await SecureStorageService.getClientBottomLogoBytes();
    background = await SecureStorageService.getClientBackgroundBytes();
    final kioskOptions = await SecureStorageService.getAdminDashboardSettings();

    if (kioskOptions != null && kioskOptions.isNotEmpty) {

      debugPrint(kioskOptions);
      final kioskOptionsData = jsonDecode(kioskOptions) as Map<String, dynamic>;
      _enableVisitorSignIn = kioskOptionsData['enable_visitor_sign_in'] ?? true;
      _enableVisitorSignOut = kioskOptionsData['enable_visitor_sign_out'] ?? true;
      _enableVisitorDelivery = kioskOptionsData['enable_visitor_delivery'] ?? false;
      _enableContractorSignIn = kioskOptionsData['enable_contractor_sign_in'] ?? false;
      _enableContractorSignOut = kioskOptionsData['enable_contractor_sign_out'] ?? false;
      _enableVisitorRetrieveBadge = kioskOptionsData['enable_visitor_retrieve_badge'] ?? false;
    }
    // if this is equal to 'kiosk_dashboard' then skill to kiosk page 
    await SecureStorageService.saveLastKioskAccess('kiosk_dashboard');

    //check local token
    //check local selected site
    //check local client

    _isCheckingInitial = false;
    notifyListeners();
  }

  Future<void> logOutKioskDashboard () async {
    //false -> last access site
    await SecureStorageService.saveLastKioskAccess('none');
  }

}
