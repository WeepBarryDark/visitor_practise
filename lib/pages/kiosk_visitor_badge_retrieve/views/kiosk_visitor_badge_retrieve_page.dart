import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_badge_retrieve/controllers/kiosk_visitor_badge_retrieve_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_badge_retrieve/widgets/kiosk_visitor_badge_retrieve_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorBadgeRetrievePage extends StatefulWidget {
  const KioskVisitorBadgeRetrievePage({super.key});

  @override
  State<KioskVisitorBadgeRetrievePage> createState() => _KioskVisitorBadgeRetrievePageState();
}

class _KioskVisitorBadgeRetrievePageState extends State<KioskVisitorBadgeRetrievePage> {
  late final KioskVisitorBadgeRetrieveController _kioskVisitorBadgeRetrieveController;
  late final KioskDashboardController _kioskController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get kioskController from navigation arguments
      _kioskController = ModalRoute.of(context)!.settings.arguments as KioskDashboardController;

      _kioskVisitorBadgeRetrieveController = KioskVisitorBadgeRetrieveController();
      _kioskVisitorBadgeRetrieveController.initialiseWithKioskController(_kioskController);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _kioskVisitorBadgeRetrieveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskVisitorBadgeRetrieveController,
      builder: (context, child) {
        if (_kioskVisitorBadgeRetrieveController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from kiosk controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskVisitorBadgeRetrieveController.background!,
          mainWidget: KioskGuardParent(
            child: KioskVisitorBadgeRetrieveMain(
              kioskVisitorBadgeRetrieveController: _kioskVisitorBadgeRetrieveController,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}