import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/controllers/kiosk_visitor_final_badge_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';

class KioskVisitorFinalBadgeMain extends StatelessWidget {
  const KioskVisitorFinalBadgeMain({
    super.key,
    required this.kioskVisitorFinalBadgeController,
    required this.maxBodyWidth,
  });

  final KioskVisitorFinalBadgeController kioskVisitorFinalBadgeController;
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
              headLogoUrl: kioskVisitorFinalBadgeController.logoImageUrl, 
              siteTitle: "test", 
              printReady: true, 
              supervisorName: "Barry Wang",
              menuContent: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your visitor badge has been generated',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    //badge image preview box

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                            maxHeight: 800,
                          ),
                          child: RawImage(
                            //image: kioskVisitorFinalBadgeController.logoImageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Print Progress Display (only show if printing is enabled)
                    /*
                    if (controller.printVisitorBadge) ...[
                      PrintProgressWidget(
                        progress: controller.printProgress,
                        showIcon: true,
                        showTimestamp: false,
                      ),
                      const SizedBox(height: 16),
                    ],
                    */

                    //Button, you can only click it when print is done
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: kioskVisitorFinalBadgeController.isCheckingInitial ? null : null,
                        icon: kioskVisitorFinalBadgeController.isCheckingInitial
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              )
                            : const Icon(Icons.home),
                        label: Text(
                          kioskVisitorFinalBadgeController.isCheckingInitial ? 'Please wait...' : 'Return to Kiosk',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              buttonLogoUrl: kioskVisitorFinalBadgeController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}