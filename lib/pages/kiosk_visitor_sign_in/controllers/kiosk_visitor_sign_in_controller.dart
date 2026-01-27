import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';

class KioskVisitorSignInController {

    // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;

  final bool _showFullName = true; //mandatory
  bool get showFullName => _showFullName; 
  final bool _showEmail = true; //mandatory
  bool get showEmail => _showEmail; 
  final bool _showPhone = true;
  bool get showPhone => _showPhone; 
  final bool _showCompany = true;
  bool get showCompany => _showCompany; 
  final bool _showAddress = true;
  bool get showAddress => _showAddress; 
  final bool _showWorkType = true;
  bool get showWorkType => _showWorkType; 
  final bool _showContactDetail = true;
  bool get showContactDetail => _showContactDetail; 
  final bool _showSignInTime = true;
  bool get showSignInTime => _showSignInTime; 
  final List<ContactDetail> _availableContactDetail = [];


  //All input fields
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final workTypeCtrl = TextEditingController();
  final TextEditingController signInTimeCtrl = TextEditingController();

  bool _useCustomBackground = false;
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String logoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String powerByLogoUrl = "lib/assets/images/Worx_PoweredBy_Logo_Mono.png";
}

