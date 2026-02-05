import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskDashboardController extends ChangeNotifier {

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial; 

  bool _useCustomBackground = false;
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String logoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String powerByLogoUrl = "lib/assets/images/Worx_PoweredBy_Logo_Mono.png";

  Future<void> initializing () async {
    //check local token
    //check local selected site
    //check local client
  }

  Future<void> logOutKioskDashboard () async {
    //false -> last access site
    final lastAccessedSite = {
      'isLastAccessKiosk': false,
    };

    await SecureStorageService.saveLastAccess(jsonEncode(lastAccessedSite));
  }

}
