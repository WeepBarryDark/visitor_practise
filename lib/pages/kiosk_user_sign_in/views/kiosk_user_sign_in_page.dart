import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_user_sign_in/controllers/kiosk_user_sign_in_controller.dart';
import 'package:visitor_practise/pages/kiosk_user_sign_in/widgets/kiosk_user_sign_in_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskUserSignInPage extends StatefulWidget {
  const KioskUserSignInPage({super.key});

  @override
  State<KioskUserSignInPage> createState() => _KioskUserSignInPageState();
}

class _KioskUserSignInPageState extends State<KioskUserSignInPage> {
 late final KioskUserSignInController _kioskUserSignInController;

  @override
  void initState() {
    super.initState();
    _kioskUserSignInController = KioskUserSignInController();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskUserSignInController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskUserSignInController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskUserSignInMain(kioskUserSignInController: _kioskUserSignInController,maxBodyWidth:maxBodyWidth)),
    );
  }
}