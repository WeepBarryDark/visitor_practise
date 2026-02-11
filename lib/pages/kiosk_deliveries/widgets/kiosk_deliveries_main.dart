import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_deliveries/controllers/kiosk_deliveries_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/kiosk_field.dart';

class KioskDeliveriesMain extends StatelessWidget {
  const KioskDeliveriesMain({
    super.key,
    required this.kioskDeliveriesController,
    required this.maxBodyWidth,
  });

  final KioskDeliveriesController kioskDeliveriesController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final siteTitle = kioskDeliveriesController.getSiteTitle();
    final supervisor = kioskDeliveriesController.currentSite?.siteSupervisor.name;

    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
            topLogoBytes: kioskDeliveriesController.topLogo!,
            siteTitle: siteTitle,
            printReady: true,
            supervisorName: supervisor,
            menuContent: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Let the site supervisor know when a delivery arrives.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form - ONLY delivery company field
                  KioskField(
                    controller: kioskDeliveriesController.orgCtrl,
                    title: 'Delivery Company',
                    required: true,
                    helpText: 'This name appears in the text/email sent to the supervisor.',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
            bottomLogoBytes: kioskDeliveriesController.bottomLogo!,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final backButton = OutlinedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Back'),
    );

    final submitButton = FilledButton.icon(
      onPressed: kioskDeliveriesController.submitting
          ? null
          : () async {
              final success = await kioskDeliveriesController.submitDelivery(context);
              if (success && context.mounted) {
                // Clear form
                kioskDeliveriesController.clearForm();
                // Return to kiosk dashboard
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.kioskDashboard,
                  (route) => false,
                );
              }
            },
      icon: kioskDeliveriesController.submitting
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle),
      label: const Text('Notify Supervisor'),
    );

    // Responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 440;
        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              submitButton,
              const SizedBox(height: 12),
              backButton,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: backButton),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: submitButton),
          ],
        );
      },
    );
  }
}
