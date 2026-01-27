import 'package:flutter/material.dart';
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
    return Align(
      alignment: AlignmentGeometry.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
              headLogoUrl: kioskDeliveriesController.logoImageUrl, 
              siteTitle: "test", 
              printReady: true, 
              supervisorName: "Barry Wang",
              menuContent: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text('Delivery Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      //key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                          const SizedBox(height: 12),
                        ],
                      )
                    ),
                                        Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context), // return to kiosk dashboard
                          label: const Text('Back'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: kioskDeliveriesController.submitting ? null : () => { print('nothing')},
                          child: kioskDeliveriesController.submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buttonLogoUrl: kioskDeliveriesController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}