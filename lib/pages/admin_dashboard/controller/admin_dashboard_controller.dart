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


  //
  Future<void> initialise ({
    required Future<void> Function() onAlreadyRedirect,
  }) async {
    final onRedirect = await checkRedirect();
    if (onRedirect) {
      // 让 page 去导航（Controller 不碰 BuildContext）
      await onAlreadyRedirect ();
      return;
    }

  }

  Future<bool> checkRedirect() async {
    return false;
  }

}