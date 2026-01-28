import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';

import 'package:visitor_practise/core/constants/server_link.dart';
import 'package:visitor_practise/core/models/auth_nav_decision.dart';
import 'package:visitor_practise/services/api_service.dart';

import 'package:visitor_practise/services/secure_storage_service.dart';

class AuthController extends ChangeNotifier {
  final Future<void> Function() onApproved;

  AuthController({
    required this.onApproved,
  });

  // ----------------state -----------------------
  bool _isCheckingInitialAuth = true;
  bool get isCheckingInitialAuth => _isCheckingInitialAuth;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _uuid;
  String? get uuid => _uuid;

  String? _qrUrl;
  String? get qrUrl => _qrUrl;

  bool _isPollingStarted = false;
  bool get isPollingStarted => _isPollingStarted;

  bool _isPolling = false;
  bool get isPolling => _isPolling;

  String _statusMessage = 'Initializing...';
  String get statusMessage => _statusMessage;


  // ---------------- Bootstrapping ----------------
  //Step 1 
  Future<void> bootstrap({
    required Future<void> Function() onAlreadyAuthed,
  }) async {
    _isCheckingInitialAuth = true;
    _hasError = false;
    _statusMessage = 'Checking if this tablet is already logged in...';
    notifyListeners();

    final alreadyAuthed = await checkExistingAuth();

    if (alreadyAuthed) {
      await onAlreadyAuthed();
      return;
    }
    generateLocalQr();

    _isCheckingInitialAuth = false;
    notifyListeners();
  }

    // ---------------- Bootstrap logic ----------------

  /// Returns TRUE if authenticated, FALSE if not.
  Future<bool> checkExistingAuth() async {
    /*
    //check if there is already an Auth Token, if so, jump to dashboard
    */
    try {
      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 50));
      final alreadyAuthed = token != null && token.isNotEmpty;

      _hasError = false;
      _statusMessage = alreadyAuthed ? 'Already authenticated on this device.' : 'No existing login found. Please scan the QR code.';
      notifyListeners();

      return alreadyAuthed;
    } on TimeoutException {
      _hasError = true;
      _statusMessage = 'Request timed out. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      _hasError = true;
      _statusMessage = 'Error while checking existing login. Please start a new session.';
      notifyListeners();
      return false;
    }
  }

  void generateLocalQr() {
    try {
      const uuidGen = Uuid(); // Universally Unique Identifier  128 bit - 122 random
      final newUuid = uuidGen.v4();

      _uuid = newUuid;
      _qrUrl = ServerLink.newSessionURL + newUuid;

      _isPollingStarted = false; 
      _isPolling = false;

      _statusMessage = "Step 1: Please scan the QR code.";
      //debugPrint(_qrUrl); https://app.worxsafety.com.au/qr-login/bb0a83b2-401c-446a-9348-c461bc8c1396
      _hasError = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _statusMessage = "Failed to generate QR code, please contact development team.";
      notifyListeners();
    }
  }

  Future<void> regenerateLocalQr() async {
    //basically reset the session
    _hasError = false;
    _statusMessage = "Generating new QR session...";
    notifyListeners();
    
    try{
      const uuidGen = Uuid();
      final newUuid = uuidGen.v4();

      _uuid = newUuid;
      _qrUrl = ServerLink.newSessionURL + newUuid;
      _statusMessage = 'Initializing...';

      //debugPrint(_qrUrl); https://app.worxsafety.com.au/qr-login/bb0a83b2-401c-446a-9348-c461bc8c1396
      _hasError = false;

      await SecureStorageService.clearAll();

      _isPollingStarted = false;
      _isPolling = false;
      _statusMessage = "Step 1: Please scan the QR code.";
      _hasError = false;

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _statusMessage = "Failed to re-generate QR code, please contact development team, may be the clear local storage error";
      notifyListeners();
    }
  }

  Future<void> startPolling() async {
    //check required parameters, and not started already
    if (_uuid == null) {
      _hasError = true;
      _statusMessage = 'QR code is not ready. Please regenerate.';
      notifyListeners();
      return;
    }

    //one more guard 
    if (_isPollingStarted) return;

    //change UI
    _isPollingStarted = true;
    _isPolling = true;
    _hasError = false;
    _statusMessage = 'Step 2: Waiting for login approval...';
    notifyListeners();

    const pollInterval = Duration(seconds: 3);
    const timeout = Duration(seconds: 60);
    final deadline = DateTime.now().add(timeout);

    try{
      while (true) {
        if (DateTime.now().isAfter(deadline)){
          _hasError = true;
          _statusMessage = 'Authentication timed out. Please restart QR login and try again.';
          return;
        }

        try {
          final data = await ApiService.authenticateDevice(setupCode: _uuid!);
          /*debugPrint(data);
          {"device_name":"BrowserName.chrome on Win32","platform":"web","browser":"BrowserName.chrome"}
          {"access_token":"209|HI62WvVzW0KxzxBHbdWsPSQhG5jnHEuSOKmLXkJAaa26fc15"}
          */
          final tokenRaw = data['access_token'];
          final token = tokenRaw is String ? tokenRaw : null;
          /*debugPrint(tokenRaw);
          209|HI62WvVzW0KxzxBHbdWsPSQhG5jnHEuSOKmLXkJAaa26fc15
          */
          if (token == null || token.isEmpty) {
            // error data format -> throw error
            throw Exception('Missing access_token in response.');
          }
          await SecureStorageService.saveAuthToken(token);

          _hasError = false;
          _statusMessage = 'Authentication successful. Loading dashboard...';
          await onApproved();
          return;
        } catch (e) {
          //
          //debugPrint('Polling attempt failed: $e');
        } 

        await Future.delayed(pollInterval);
      }
    } finally {
      _isPollingStarted = false;
      _isPolling = false;
      notifyListeners();
    }
  }

  Future<AuthNavDecision> decideNextNavigation() async {
    final savedToken = await SecureStorageService.getAuthToken();
    if (savedToken == null || savedToken.isEmpty) {
        regenerateLocalQr();
        return const AuthNavDecision.backToRoot();
    }

    //Fetch sites - need to decide navigating to new site or dashboard = site_number != 1
    try {
      final sitesJson = await ApiService.fetchVisitorSites(savedToken).timeout(const Duration(seconds: 30));
      final rawCount = sitesJson['count'];
      final rawData = sitesJson['data'];
      
      final int sitesCount = rawCount is int ? rawCount : 0;
      final List<dynamic> sites = rawData is List ? rawData : [];

      await SecureStorageService.saveSites(jsonEncode(sites));

      if (sites.length > 1 || sitesCount == 0 || sites.isEmpty) {
        return const AuthNavDecision.go(AppRoutes.newSite);
      } else {
        return const AuthNavDecision.go(AppRoutes.dashboard);
      }
    } on TimeoutException {
      debugPrint("Time out with fetch site API, please check your internet, App reset");
      regenerateLocalQr();
      return const AuthNavDecision.backToRoot();
    } catch(e) {
      debugPrint("error with fetch site API, please check your internet, App reset");
      regenerateLocalQr();
      return const AuthNavDecision.backToRoot();
    }
  }
    
}