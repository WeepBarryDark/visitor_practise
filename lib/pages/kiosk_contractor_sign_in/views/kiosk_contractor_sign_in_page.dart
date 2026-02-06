import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
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

  @override
  void initState() {
    super.initState();
    _kioskContractorSignInController = KioskContractorSignInController();
    _kioskContractorSignInController.initialise();
  }

 
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

     return ListenableBuilder(
      listenable: _kioskContractorSignInController,
      builder: (context, child) {
        if (_kioskContractorSignInController.isCheckingInitial) {
          return const LoadingCircleInterface();
        }

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