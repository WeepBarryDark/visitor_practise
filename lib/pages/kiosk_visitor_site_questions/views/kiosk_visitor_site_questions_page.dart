import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/widgets/kiosk_visitor_site_questions_main.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSiteQuestionPage extends StatefulWidget {
  const KioskVisitorSiteQuestionPage({super.key});

  @override
  State<KioskVisitorSiteQuestionPage> createState() => _KioskVisitorSiteQuestionPageState();
}

class _KioskVisitorSiteQuestionPageState extends State<KioskVisitorSiteQuestionPage> {
  late final KioskVisitorSiteQuestionsController _controller;
  String _screenSize = 'medium';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = KioskVisitorSiteQuestionsController();
    _loadScreenSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get arguments from navigation
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final visitorData = args['visitorData'] as VisitorData;
      final signInController = args['signInController'] as KioskVisitorSignInController;

      // Initialize with data from sign-in controller
      _initializeController(visitorData, signInController);
      _initialized = true;
    }
  }

  /// Initialize controller and handle errors
  Future<void> _initializeController(VisitorData visitorData, KioskVisitorSignInController signInController) async {
    final success = await _controller.initialiseWithSignInController(visitorData, signInController);

    if (!success && mounted) {
      // Show error message locally
      final errorMsg = _controller.errorMessage ?? 'Failed to load site questions. Please try again.';
      context.showError(errorMsg);

      // Wait for user to see the error
      await Future.delayed(const Duration(milliseconds: 1500));

      // Navigate back to dashboard
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.kioskDashboard,
          (route) => false,
        );
      }
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
            child: KioskVisitorSiteQuestionsMain(
              kioskVisitorSiteQuestionsController: _controller,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}
