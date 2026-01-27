import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/icon_button_general.dart';

class KioskDashboardMain extends StatelessWidget {
  const KioskDashboardMain({
    super.key,
    required this.kioskController,
    required this.maxBodyWidth,
  });

  final KioskDashboardController kioskController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
           constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
            headLogoUrl: kioskController.logoImageUrl, 
            siteTitle: "test", 
            printReady: true, 
            supervisorName: "Barry Wang",
            menuContent: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButtonGeneral(icon: Icons.person_add, label: 'Visitor Sign In',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.visitorSignIn,)),
                    const SizedBox(height: 14),
                    IconButtonGeneral(icon: Icons.logout, label: 'Visitor Sign Out',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.visitorSignOut,)),
                    const SizedBox(height: 14),
                    IconButtonGeneral(icon: Icons.local_shipping, label: 'Delivery',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.visitorDeliveries,)),
                    const SizedBox(height: 14),
                    IconButtonGeneral(icon: Icons.person_add, label: 'Contractor Sign In',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.contractorSignIn,)),
                    const SizedBox(height: 14),
                    IconButtonGeneral(icon: Icons.person_add, label: 'Re-print Badge',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.reprintBadge,)),
                  ],
                ),
              ),
            ),
            buttonLogoUrl: kioskController.powerByLogoUrl,
            footerAction: IconButton(
              tooltip: 'Admin Sign In',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => (print('should be the log out function')),
            ),
          ),
        ),
      ),
    );
  }
}


