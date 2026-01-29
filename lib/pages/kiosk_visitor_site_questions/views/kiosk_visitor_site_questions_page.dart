import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/widgets/kiosk_visitor_site_questions_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/kiosk_guard_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class KioskVisitorSiteQuestionPage extends StatefulWidget {
  const KioskVisitorSiteQuestionPage({super.key});

  @override
  State<KioskVisitorSiteQuestionPage> createState() => _KioskVisitorSiteQuestionPageState();
}

class _KioskVisitorSiteQuestionPageState extends State<KioskVisitorSiteQuestionPage> {

  late final KioskVisitorSiteQuestionsController _kioskVisitorSignIncontroller;

  @override
  void initState() {
    super.initState();
    _kioskVisitorSignIncontroller = KioskVisitorSiteQuestionsController();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskVisitorSignIncontroller.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       webNotAsset: false,
       customBackgroundUrl: _kioskVisitorSignIncontroller.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskVisitorSiteQuestionsMain(kioskVisitorSiteQuestionsController: _kioskVisitorSignIncontroller,maxBodyWidth:maxBodyWidth)),
    );
  }
}