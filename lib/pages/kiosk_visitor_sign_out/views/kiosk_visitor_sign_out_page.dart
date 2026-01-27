import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
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

  @override
  void initState() {
    super.initState();
    _kioskVisitorSignOutController = KioskVisitorSignOutController();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskVisitorSignOutController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskVisitorSignOutController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskVisitorSignOutMain(kioskVisitorSignOutController: _kioskVisitorSignOutController,maxBodyWidth:maxBodyWidth)),
    );
  }
}