import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/widgets/kiosk_visitor_site_questions_main.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorSiteQuestionPage extends StatefulWidget {
  const KioskVisitorSiteQuestionPage({super.key});

  @override
  State<KioskVisitorSiteQuestionPage> createState() => _KioskVisitorSiteQuestionPageState();
}

class _KioskVisitorSiteQuestionPageState extends State<KioskVisitorSiteQuestionPage> {

  late final KioskVisitorSiteQuestionsController _kioskVisitorSignIncontroller;
  String _screenSize = 'medium';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _kioskVisitorSignIncontroller = KioskVisitorSiteQuestionsController();
    _loadScreenSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get visitor data from navigation arguments
      final visitorData = ModalRoute.of(context)!.settings.arguments as VisitorData;
      _kioskVisitorSignIncontroller.initialise(visitorData);
      _initialized = true;
    }
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


  @override
  Widget build(BuildContext context) {
    // Use screen size setting from storage
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width, screenSize: _screenSize);
    
    return ListenableBuilder(
      listenable: _kioskVisitorSignIncontroller,
      builder: (context, child) {
        if (_kioskVisitorSignIncontroller.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        return BackgroundImageParent(
          backgroundBytes: _kioskVisitorSignIncontroller.background!,
          mainWidget: KioskGuardParent(
            child: KioskVisitorSiteQuestionsMain(
              kioskVisitorSiteQuestionsController: _kioskVisitorSignIncontroller,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}