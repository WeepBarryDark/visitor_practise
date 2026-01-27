import 'package:flutter/material.dart';

class KioskDeliveriesController {
  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;
  bool _useCustomBackground = false;

  //form input field controller
   late final TextEditingController orgCtrl;

  
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String logoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String powerByLogoUrl = "lib/assets/images/Worx_PoweredBy_Logo_Mono.png";
}