import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/widgets/kiosk_dashboard_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskDashboardPage extends StatefulWidget {
  const KioskDashboardPage({super.key});

  @override
  State<KioskDashboardPage> createState() => _KioskDashboardPageState();
}

class _KioskDashboardPageState extends State<KioskDashboardPage> {
  late final KioskDashboardController _kioskDashboardController;

  @override
  void initState() {
    super.initState();
    _kioskDashboardController = KioskDashboardController();

    // Wait for first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _kioskDashboardController.initializing(
          onFailInitialization:(nextRoute) async => _failInitializationNavigation(nextRoute),
          context: context,
        );
      }
    });
  }

  Future<void> _failInitializationNavigation(String nextRoute) async {
    try {
      Navigator.of(context).pushReplacementNamed(nextRoute);
    } catch (e) {
      if (!mounted) return;
      context.showError(
        "Offline or Server Unreachable. Check Internet Connection and restart this app. If it's not internet issue, please contact developer.",
        duration: const Duration(seconds: 5),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _kioskDashboardController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskDashboardController,
      builder: (context, child) {
        if (_kioskDashboardController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskDashboardController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskDashboardController.background!,
          mainWidget: KioskGuardParent(
            child: KioskDashboardMain(
              kioskController: _kioskDashboardController,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}