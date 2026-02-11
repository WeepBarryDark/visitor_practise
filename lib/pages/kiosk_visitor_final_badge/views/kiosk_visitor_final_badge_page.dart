import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/controllers/kiosk_visitor_final_badge_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/widgets/kiosk_visitor_final_badge_main.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorFinalBadgePage extends StatefulWidget {
  const KioskVisitorFinalBadgePage({super.key});

  @override
  State<KioskVisitorFinalBadgePage> createState() => _KioskVisitorFinalBadgePageState();
}

class _KioskVisitorFinalBadgePageState extends State<KioskVisitorFinalBadgePage> {
  late final KioskVisitorFinalBadgeController _controller;
  String _screenSize = 'medium';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = KioskVisitorFinalBadgeController();
    _loadScreenSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get arguments from navigation
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final siteQuestionsController = args['siteQuestionsController'] as KioskVisitorSiteQuestionsController;

      // Initialize with data from site questions controller
      _controller.initialiseWithSiteQuestionsController(siteQuestionsController, context);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use screen size setting from storage
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width, screenSize: _screenSize);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        return BackgroundImageParent(
          backgroundBytes: _controller.background!,
          mainWidget: KioskGuardParent(
            child: KioskVisitorFinalBadgeMain(
              kioskVisitorFinalBadgeController: _controller,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}
