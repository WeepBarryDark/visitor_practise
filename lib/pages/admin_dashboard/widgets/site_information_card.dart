import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/admin_dashboard/controller/admin_dashboard_controller.dart';
import 'package:visitor_practise/shared_widgets/site_info_row.dart';

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
              'Welcome, ${adminController.clientName} team',
              textAlign: TextAlign.center,
              style: tt.titleLarge,
            ),
            const SizedBox(height: 12,),
            Center(
              child: Image.asset(
                      'lib/assets/images/WorxSafety_Logo_NoShadow.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Selected Site', style: tt.titleMedium)),
                FilledButton.icon(
                  onPressed: () async {
                    print('jump to site');
                  }, 
                  icon: const Icon(Icons.sync),
                  label: const Text('Change Site'),
                )
              ],
            ),
            const SizedBox(height: 16),
            SiteInfoRow(
              label: 'Site Name',
              value: 'Example Site Names',
            ),
            const SizedBox(height: 16),
            SiteInfoRow(
              label: 'Address',
              value: 'Example Site Names long long Example Site Names long long',
            ),
            
            //Site name display

          ],
        ),
      )
    );
  }
}