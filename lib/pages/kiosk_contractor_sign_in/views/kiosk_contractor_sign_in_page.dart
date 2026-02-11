import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_contractor_sign_in/controllers/kiosk_contractor_sign_in_controller.dart';
import 'package:visitor_practise/pages/kiosk_contractor_sign_in/widgets/kiosk_contractor_sign_in_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskContractorSignInPage extends StatefulWidget {
  const KioskContractorSignInPage({super.key});

  @override
  State<KioskContractorSignInPage> createState() => _KioskContractorSignInPageState();
}

class _KioskContractorSignInPageState extends State<KioskContractorSignInPage> {
  late final KioskContractorSignInController _kioskContractorSignInController;
  late final KioskDashboardController _kioskController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get kioskController from navigation arguments
      _kioskController = ModalRoute.of(context)!.settings.arguments as KioskDashboardController;

      _kioskContractorSignInController = KioskContractorSignInController();
      _kioskContractorSignInController.initialiseWithKioskController(_kioskController);
      _initialized = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskContractorSignInController,
      builder: (context, child) {
        if (_kioskContractorSignInController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from kiosk controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskContractorSignInController.background!,
          mainWidget: KioskGuardParent(
            child: KioskContractorSignInMain(
              kioskContractorSignInController: _kioskContractorSignInController,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}