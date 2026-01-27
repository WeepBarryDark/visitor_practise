import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
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

  @override
  void initState() {
    super.initState();
    _kioskVisitorBadgeRetrieveController = KioskVisitorBadgeRetrieveController();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskVisitorBadgeRetrieveController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskVisitorBadgeRetrieveController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskVisitorBadgeRetrieveMain(kioskVisitorBadgeRetrieveController: _kioskVisitorBadgeRetrieveController,maxBodyWidth:maxBodyWidth)),
    );
  }
}