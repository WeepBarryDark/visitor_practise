import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_user_sign_in/controllers/kiosk_user_sign_in_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';

class KioskUserSignInMain extends StatelessWidget {
  const KioskUserSignInMain({
    super.key,
    required this.kioskUserSignInController,
    required this.maxBodyWidth,
  });

  final KioskUserSignInController kioskUserSignInController;
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
              headLogoUrl: kioskUserSignInController.logoImageUrl, 
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
                          onPressed: kioskUserSignInController.submitting ? null : () => {print('jump to new site with all data')},
                          child: kioskUserSignInController.submitting
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
              buttonLogoUrl: kioskUserSignInController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}