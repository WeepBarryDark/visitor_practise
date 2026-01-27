import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/controllers/kiosk_visitor_final_badge_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/widgets/kiosk_visitor_final_badge_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorFinalBadgePage extends StatefulWidget {
  const KioskVisitorFinalBadgePage({super.key});

  @override
  State<KioskVisitorFinalBadgePage> createState() => _KioskVisitorFinalBadgePageState();
}

class _KioskVisitorFinalBadgePageState extends State<KioskVisitorFinalBadgePage> {

 late final KioskVisitorFinalBadgeController _kioskVisitorFinalBadgeController;

  @override
  void initState() {
    super.initState();
    _kioskVisitorFinalBadgeController = KioskVisitorFinalBadgeController();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskVisitorFinalBadgeController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskVisitorFinalBadgeController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskVisitorFinalBadgeMain(kioskVisitorFinalBadgeController: _kioskVisitorFinalBadgeController,maxBodyWidth:maxBodyWidth)),
    );
  }
}