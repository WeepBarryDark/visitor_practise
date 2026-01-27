import 'dart:typed_data';

import 'package:flutter/material.dart';

class KioskVisitorBadgeRetrieveController {

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;
  bool _useCustomBackground = false;

  final visitorIdCtrl = TextEditingController();
  
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  Uint8List?  badgeImageBytes;

  bool _useCustomLogo = true;
  String logoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String powerByLogoUrl = "lib/assets/images/Worx_PoweredBy_Logo_Mono.png";

}