import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/widgets/kiosk_dashboard_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskDashboardController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskDashboardController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskDashboardMain(kioskController: _kioskDashboardController,maxBodyWidth:maxBodyWidth)),
    );
  }
}