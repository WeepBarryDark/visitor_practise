import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskVisitorSignInController {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

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

  Future<void> initialise() async {
    topLogo = await SecureStorageService.getClientTopLogoBytes();
    bottomLogo = await SecureStorageService.getClientTopLogoBytes();
    background = await SecureStorageService.getClientBackgroundBytes();
  }
}

