import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/widgets/kiosk_visitor_sign_in_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSignInPage extends StatefulWidget {
  const KioskVisitorSignInPage({super.key});

  @override
  State<KioskVisitorSignInPage> createState() => _KioskVisitorSignInPageState();
}

class _KioskVisitorSignInPageState extends State<KioskVisitorSignInPage> {
  late final KioskVisitorSignInController _kioskVisitorSignIncontroller;
  late final KioskDashboardController _kioskController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get kioskController from navigation arguments
      _kioskController = ModalRoute.of(context)!.settings.arguments as KioskDashboardController;

      _kioskVisitorSignIncontroller = KioskVisitorSignInController();
      _initializeController();
      _initialized = true;
    }
  }

  /// Initialize controller and handle errors
  Future<void> _initializeController() async {
    final success = await _kioskVisitorSignIncontroller.initialiseWithKioskController(_kioskController);

    if (!success && mounted) {
      // Show error message locally
      final errorMsg = _kioskVisitorSignIncontroller.errorMessage ?? 'Failed to load contacts. Please try again.';
      context.showError(errorMsg);

      // Wait for user to see the error
      await Future.delayed(const Duration(milliseconds: 1500));

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _kioskVisitorSignIncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskVisitorSignIncontroller,
      builder: (context, child) {
        if (_kioskVisitorSignIncontroller.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from kiosk controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskVisitorSignIncontroller.background!,
          mainWidget: KioskGuardParent(
            child: KioskVisitorSignInMain(
              kioskVisitorSignInController: _kioskVisitorSignIncontroller,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}