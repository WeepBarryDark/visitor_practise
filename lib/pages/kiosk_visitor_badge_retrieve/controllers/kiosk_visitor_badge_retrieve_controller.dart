import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskVisitorBadgeRetrieveController extends ChangeNotifier{
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;

  final visitorIdCtrl = TextEditingController();
  
  Future<void> initialise() async {
    topLogo = await SecureStorageService.getClientTopLogoBytes();
    bottomLogo = await SecureStorageService.getClientTopLogoBytes();
    background = await SecureStorageService.getClientBackgroundBytes();
    notifyListeners();
    
  }
}