import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
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

  @override
  void initState() {
    super.initState();
    _kioskDeliveriesController = KioskDeliveriesController();
    _kioskDeliveriesController.orgCtrl = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    if (!_kioskDeliveriesController.isCheckingInitial) {
      return const LoadingCircleInterface();
    }
    
    return BackgroundImageParent(
       customBackgroundUrl: _kioskDeliveriesController.backgroundImageUrl,
       mainWidget: KioskGuardParent(child:KioskDeliveriesMain(kioskDeliveriesController: _kioskDeliveriesController,maxBodyWidth:maxBodyWidth)),
    );
  }
}