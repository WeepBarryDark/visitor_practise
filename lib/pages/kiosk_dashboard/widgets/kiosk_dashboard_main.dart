import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_dashboard/controllers/kiosk_dashboard_controller.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/admin_password_dialog.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/icon_button_general.dart';
import 'package:visitor_practise/shared_widgets/persistent_error_banner.dart';

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
    return Column(
      children: [
        // Show persistent error banner if there's an error
        if (kioskController.persistentErrorMessage != null)
          PersistentErrorBanner(
            message: kioskController.persistentErrorMessage!,
          ),
        // Main content
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBodyWidth),
                child: KioskBody(
                  topLogoBytes: kioskController.topLogo!,
                  siteTitle: kioskController.currentSite.title,
                  printReady: kioskController.isPrinterReady,
                  supervisorName: kioskController.currentSite.siteSupervisor.name,
                  menuContent: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if(kioskController.enableVisitorSignIn)
                            IconButtonGeneral(icon: Icons.person_add, label: 'Visitor Sign In',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.kioskVisitorSignIn, arguments: kioskController,)),
                          const SizedBox(height: 14),
                          if(kioskController.enableVisitorSignIn)
                            IconButtonGeneral(icon: Icons.logout, label: 'Visitor Sign Out',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.kioskVisitorSignOut, arguments: kioskController,)),
                          const SizedBox(height: 14),
                          if(kioskController.enableVisitorDelivery)
                            IconButtonGeneral(icon: Icons.local_shipping, label: 'Delivery',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.kioskDeliveries, arguments: kioskController,)),
                          const SizedBox(height: 14),
                          if(kioskController.enableContractorSignIn)
                            IconButtonGeneral(icon: Icons.person_add, label: 'Contractor Sign In',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.kioskContractorSignIn, arguments: kioskController,)),
                          const SizedBox(height: 14),
                          if(kioskController.enableVisitorRetrieveBadge)
                            IconButtonGeneral(icon: Icons.person_add, label: 'Retrieve Badge',  onPressed:  () => Navigator.pushNamed(context, AppRoutes.kioskVisitorBadgeRetrieve, arguments: kioskController,)),
                        ],
                      ),
                    ),
                  ),
                  bottomLogoBytes: kioskController.bottomLogo!,
                  footerAction: IconButton(
                    tooltip: 'Admin Sign In',
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () async {
                      final success = await showDialog<bool>(context: context, builder: (context) => const AdminPasswordDialog(),);
                      if (success == true && context.mounted) {
                        await SecureStorageService.saveLastKioskAccess('none');
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(context,AppRoutes.adminDashboard, (route) => false,);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


