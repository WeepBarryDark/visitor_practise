import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_out/controllers/kiosk_visitor_sign_out_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_out/widgets/kiosk_visitor_sign_out_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorSignOutPage extends StatefulWidget {
  const KioskVisitorSignOutPage({super.key});

  @override
  State<KioskVisitorSignOutPage> createState() => _KioskVisitorSignOutPageState();
}

class _KioskVisitorSignOutPageState extends State<KioskVisitorSignOutPage> {
  late final KioskVisitorSignOutController _kioskVisitorSignOutController;
  late final KioskDashboardController _kioskController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get kioskController from navigation arguments
      _kioskController = ModalRoute.of(context)!.settings.arguments as KioskDashboardController;

      _kioskVisitorSignOutController = KioskVisitorSignOutController();
      _kioskVisitorSignOutController.initialiseWithKioskController(_kioskController);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _kioskVisitorSignOutController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskVisitorSignOutController,
      builder: (context, child) {
        if (_kioskVisitorSignOutController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from kiosk controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskVisitorSignOutController.background!,
          mainWidget: KioskGuardParent(
            child: KioskVisitorSignOutMain(
              kioskVisitorSignOutController: _kioskVisitorSignOutController,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}