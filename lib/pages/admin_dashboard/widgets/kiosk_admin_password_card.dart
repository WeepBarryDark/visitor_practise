import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';

class KioskAdminPasswordCard extends StatelessWidget {
  const KioskAdminPasswordCard({
    super.key,
    required this.adminController
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
            Text('Kiosk Admin Password', style: tt.titleMedium),
            const SizedBox(height: 4),
            Text(
              'This password is required when tapping "Admin Sign In" on the kiosk. '
              'Share it only with trusted staff.',
              style: tt.bodySmall?.copyWith(color: AppTheme.slate600),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: adminController.adminPinCtrl,
                obscureText: adminController.obscureAdminPin,
                decoration: InputDecoration(
                  labelText: 'Admin password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      adminController.obscureAdminPin ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: adminController.changePasswordVisibility,
                  ),
                  //errorText: adminPinError,
                  helperText: 'Minimum 4 characters. Numbers only recommended.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:  adminController.onSaveAdminPin,
                icon: const Icon(Icons.save),
                label: const Text('Save Password'),
              ),
          ]
        ),
      )
    );
  }
}