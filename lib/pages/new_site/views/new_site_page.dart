import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/new_site/controllers/new_siter_controllder.dart';
import 'package:visitor_practise/pages/new_site/widgets/new_site_main.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class NewSitePage extends StatefulWidget {
  const NewSitePage({super.key});
  @override
  State<NewSitePage> createState() => _NewSitePageState();
}

class _NewSitePageState extends State<NewSitePage> {
  late final NewSiterControllder _newSiteController;
  String _screenSize = 'medium';

  @override
  void initState() {
    super.initState();
    _newSiteController = NewSiterControllder();
    //Step 1 check condition, if jump to kiosk, as before unexpected jump out
    _newSiteController.initialise(
      onAlreadyRedirect: (nextRoute) async => _handleNavigationKiosk(nextRoute),
    );
    _loadScreenSize();
  }

  Future<void> _loadScreenSize() async {
    try {
      final settings = await SecureStorageService.getAdminDashboardSettings();
      if (settings != null && settings.isNotEmpty) {
        final data = jsonDecode(settings) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _screenSize = data['screen_size'] ?? 'medium';
          });
        }
      }
    } catch (e) {
      // Use default if loading fails
    }
  }

  Future<void> _handleNavigationKiosk(String nextRoute) async {
    final nav = Navigator.of(context);
    final messagerWindow = ScaffoldMessenger.of(context);

    try {
      nav.pushReplacementNamed(nextRoute);
    } catch (e) {
      if (!mounted) return;
      messagerWindow.showSnackBar(
        const SnackBar(
          content: Text(
            "Offline or Server Unreachable. Check Internet Connection and restart this app. If it's not internet issue, please contact developer.",
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width, screenSize: _screenSize);

    return AnimatedBuilder(
        animation: _newSiteController,
        builder: (context, _) {
          if (_newSiteController.isCheckingInitialSite) {
            return const LoadingCircleInterface();
          }

          return AppShell(
            title: 'Sites List',
            child: BackgroundImageParent(
              backgroundBytes: _newSiteController.background!,
              mainWidget: NewSiteMain(
                newSiteControllder: _newSiteController,
                maxBodyWidth: maxBodyWidth,
              ),
            ),
          );
        },
      );
  }
}