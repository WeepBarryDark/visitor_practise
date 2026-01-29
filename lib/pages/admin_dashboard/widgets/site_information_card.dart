import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:visitor_practise/services/helper/logo_builder.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/site_info_row.dart';

class SiteInformationCard extends StatelessWidget {
  const SiteInformationCard({
    super.key,
    required this.adminController,
    });

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${adminController.clientDisplayName} team',
              textAlign: TextAlign.center,
              style: tt.titleLarge,
            ),
            const SizedBox(height: 12,),
            Center(
              child: FittedBox(
            fit:BoxFit.contain,
                child: adminController.useCustomLogo
                  ? LogoBuilder(adminController.logoImageUrl, 48)
                  : Image.asset(adminController.logoImageUrl, height: 48),
                )
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Selected Site', style: tt.titleMedium)),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.newSite,
                    );
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Change Site'),
                )
              ],
            ),
            const SizedBox(height: 16),
            SiteInfoRow(
              label: 'Site Name',
              value: adminController.siteMap?['title'],
            ),
            const SizedBox(height: 16),
            SiteInfoRow(
              label: 'Address',
              value:  adminController.siteMap?['address'],
            ),
            //Site name display
          ],
        ),
      )
    );
  }
}