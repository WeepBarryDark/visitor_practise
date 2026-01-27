import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/widgets/kiosk_dashboard_main.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/widgets/kiosk_visitor_sign_in_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorSignInPage extends StatefulWidget {
  const KioskVisitorSignInPage({super.key});

  @override
  State<KioskVisitorSignInPage> createState() => _KioskVisitorSignInPageState();
}

class _KioskVisitorSignInPageState extends State<KioskVisitorSignInPage> {
  late final KioskVisitorSignInController _kioskVisitorSignIncontroller;

  @override
  void initState() {
    super.initState();
    _kioskVisitorSignIncontroller = KioskVisitorSignInController();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskVisitorSignIncontroller.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskVisitorSignIncontroller.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskVisitorSignInMain(kioskVisitorSignInController: _kioskVisitorSignIncontroller,maxBodyWidth:maxBodyWidth)),
    );
  }
}