import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskDashboardController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial; 

  Future<void> initializing () async {
    topLogo = await SecureStorageService.getClientTopLogoBytes();
    bottomLogo = await SecureStorageService.getClientBottomLogoBytes();
    background = await SecureStorageService.getClientBackgroundBytes();
    
    await SecureStorageService.saveLastKioskAccess('kiosk_dashboard');

    //check local token
    //check local selected site
    //check local client

    _isCheckingInitial = false;
    notifyListeners();
  }

  Future<void> logOutKioskDashboard () async {
    //false -> last access site
    final lastAccessedSite = {
      'isLastAccessKiosk': false,
    };

    await SecureStorageService.saveLastKioskAccess('none');
  }

}
