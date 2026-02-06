import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/logos_background.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class NewSiterControllder extends ChangeNotifier {
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;


  bool _isCheckingInitialSite = true;
  bool get isCheckingInitialSite => _isCheckingInitialSite;

  bool _hasError = false;
  bool get hasError => _hasError;

  List<SiteItem> _allSites = [];
  List<SiteItem> get allSites => _allSites;

  //Search bar attribute
  String searchQuery = '';
  final searchCtrl = TextEditingController();


  Future<void> initialise ({
    required Future<void> Function(String nextRoute) onAlreadyRedirect,
  }) async {
    try {
      final savedToken = await  SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (savedToken == null || savedToken.isEmpty) {
         throw Exception('No token');
      }
      // check whether redirect to Kiosk Directly----------
      final alreadyAuthed = await checkExistingAuth();
      if (alreadyAuthed) {
        await onAlreadyRedirect(AppRoutes.kioskDashboard);
        return;
      }
      //-------------------------------------------------end
      final clientJson = await ApiService.fetchVisitorClient(savedToken).timeout(const Duration(seconds: 5));
      //debugPrint(jsonEncode(clientJson));
      //{"logo":"https://storage.worxsafety.com.au/site/public/22080/pblogo.svg","background_image":"https://storage.worxsafety.com.au/site/public/7/60dbb67c245b3_bg-masthead.jpg","slug":"pinkbatteries","name":"HUGH ARTHUR TORNEY","trading_name":"Pink Batteries"}
      await SecureStorageService.saveClient(jsonEncode(clientJson));

      final clientLogo = clientJson['logo'];
      final clientBackgroundImage = clientJson['background_image'];
      final clientTradingName = clientJson['trading_name'];
      final clientName = clientJson['name'];
      final clientSlug = clientJson['slug'];

      if (clientTradingName == null || clientName == null || clientSlug == null) {
        throw Exception('No client essential data collected');
      }

      final logoBackgroundModel = await LogosBackground.create(customTopLogUrl: clientLogo, customBackground: clientBackgroundImage);
      await logoBackgroundModel.saveTolocal();

      topLogo = await SecureStorageService.getClientTopLogoBytes();
      bottomLogo = await SecureStorageService.getClientTopLogoBytes();
      background = await SecureStorageService.getClientBackgroundBytes();

      //everytime refetch sites
      final sitesJson = await ApiService.fetchVisitorSites(savedToken).timeout(const Duration(seconds: 10));
      //debugPrint(jsonEncode(sitesJson));
      //{"count ":38,"data":[{"id":1,"name":"1002567 Thirroul Development - Alternate Loc 1002567 Thirroul Development - Alternate Loc",
      //"address":"50 Redman Ave1, THIRROUL, NSW, 25001, Australia","streetAddress":"50 Redman Ave1",
      //"suburb":null,"state":"NSW","postcode":"25001","country":"Australia","latitude":-34.27741962,
      //"longitude":150.95425334,"contact":"04057654387","managerName":"Luke One1","customerName":"Test CLIENT1","customerContact":"0400000123",
      //"supervisor":{"id":25214,"name":"Barry Weep Admin"},"createdOn":"2021-08-10T03:59:45+00:00"} ...
      await SecureStorageService.saveSites(jsonEncode(sitesJson));

      final raw = sitesJson['data'];
      final List<dynamic> rawList = raw is List ? raw : <dynamic>[];
      _allSites = rawList.whereType<Map<String, dynamic>>().map(SiteItem.fromJson).toList();

      _isCheckingInitialSite = false;
      notifyListeners();

    } on TimeoutException {
      debugPrint('new site controller initialise time out');
      _hasError = true;
      notifyListeners();
      
    } catch (e) {
      debugPrint('new site controller initialise failed');
      _hasError = true;
      notifyListeners();
    }
  }

  Future<bool> checkExistingAuth() async {
    /*
    //check if there is already an Auth Token
    //if last saved location is kiosk dashboard && token, selected site, setting are not empty
    */
    try {
      final lastAccess = await SecureStorageService.getLastKioskAccess().timeout(const Duration(seconds: 50));
      if (lastAccess == 'kiosk_dashboard')
      {
        //TODO
        final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 50));
        final alreadyAuthed = token != null && token.isNotEmpty;

        _hasError = false;
        notifyListeners();

        return alreadyAuthed; // return true -> jump to kiosk dashboard
      }
      return false;
    } on TimeoutException {
      // not sure what to do now, when an error and timeout
      _hasError = true;
      notifyListeners();
      return false;
    } catch (e) {
      // not sure what to do now, when an error and timeout
      _hasError = true;
      notifyListeners();
      return false;
    }
  }

  //Search Section-------------------------------------------------------------------------
  /// Get filtered sites based on current search query and active filter
  List<SiteItem> get filtered {
    Iterable<SiteItem> items = _allSites;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.address.toLowerCase().contains(q) ||
          e.siteManager.toLowerCase().contains(q) ||
          e.siteSupervisor.toLowerCase().contains(q));
    }

    return items.toList(growable: false);
  }

  /// Update search query
  void updateSearch(String q) {
    searchQuery = q.trim();
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    searchQuery = '';
    searchCtrl.clear();
    notifyListeners();
  }

}

