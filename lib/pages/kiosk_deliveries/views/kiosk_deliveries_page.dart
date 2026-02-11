import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/app_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_deliveries/controllers/kiosk_deliveries_controller.dart';
import 'package:visitor_practise/pages/kiosk_deliveries/widgets/kiosk_deliveries_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskDeliveriesPage extends StatefulWidget {
  const KioskDeliveriesPage({super.key});

  @override
  State<KioskDeliveriesPage> createState() => _KioskDeliveriesPageState();
}

class _KioskDeliveriesPageState extends State<KioskDeliveriesPage> {
  late final KioskDeliveriesController _kioskDeliveriesController;
  late final KioskDashboardController _kioskController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get kioskController from navigation arguments
      _kioskController = ModalRoute.of(context)!.settings.arguments as KioskDashboardController;

      _kioskDeliveriesController = KioskDeliveriesController();
      _kioskDeliveriesController.initialiseWithKioskController(_kioskController);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _kioskDeliveriesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _kioskDeliveriesController,
      builder: (context, child) {
        if (_kioskDeliveriesController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

        // Use screen size setting from kiosk controller
        final width = MediaQuery.of(context).size.width;
        final maxBodyWidth = AppBreakpoints.getContentWidth(
          width,
          screenSize: _kioskController.screenSize,
        );

        return BackgroundImageParent(
          backgroundBytes: _kioskDeliveriesController.background!,
          mainWidget: KioskGuardParent(
            child: KioskDeliveriesMain(
              kioskDeliveriesController: _kioskDeliveriesController,
              maxBodyWidth: maxBodyWidth,
            ),
          ),
        );
      },
    );
  }
}