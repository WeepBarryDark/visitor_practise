import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class KioskDeliveriesController extends ChangeNotifier {
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _submitting = false;
  bool get submitting => _submitting;

  //form input field controller
   late final TextEditingController orgCtrl;

  Future<void> initialise() async {
    topLogo = await SecureStorageService.getClientTopLogoBytes();
    bottomLogo = await SecureStorageService.getClientBottomLogoBytes();
    background = await SecureStorageService.getClientBackgroundBytes();

    _isCheckingInitial = false;
    notifyListeners();
  }


}