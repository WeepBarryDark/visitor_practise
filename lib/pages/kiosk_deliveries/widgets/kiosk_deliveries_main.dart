import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_deliveries/controllers/kiosk_deliveries_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';

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
      alignment: AlignmentGeometry.topCenter,
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
                    Text('Please answer the following before completing sign in.', style: Theme.of(context).textTheme.titleMedium,),
                    const SizedBox(height: 16),
                    //---------------------------------------site question here
          
                    //----------------------------------------site question end
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: const Text('Back'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: kioskDeliveriesController.submitting ? null : () => {print('jump to new site with all data')},
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