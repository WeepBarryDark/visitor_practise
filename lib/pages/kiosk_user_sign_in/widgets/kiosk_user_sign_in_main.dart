import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
      alignment: AlignmentGeometry.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
              headLogoUrl: kioskUserSignInController.logoImageUrl, 
              siteTitle: "test", 
              printReady: true, 
              supervisorName: "Barry Wang",
              menuContent: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Contractor Registration',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                
                      // Instructions
                      Text(
                        'Scan the QR code below with your mobile device to complete user sign in',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                
                      //QR code
                      Center(
                        child: Container(
                           decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              QrImageView(
                                key: ValueKey("www.4399.com"), // Force rebuild when URL changes
                                data: "www.4399.com",
                                version: QrVersions.auto,
                                size: 280,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.link, color: Theme.of(context).colorScheme.primary, size: 20,),
                                  const SizedBox(width: 4),
                                  Text(
                                    "www.4399.com",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: Theme.of(context).colorScheme.onSurfaceVariant,),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Next Visitor Button
                      Center(
                        child: SizedBox(
                          width: maxBodyWidth / 1.5,
                          child: FilledButton.icon(
                            //onPressed: () => Navigator.pop(context),
                            onPressed: () => {print('jump out'),},
                            icon: const Icon(Icons.arrow_forward, size: 22),
                            label: const Text('Next Visitor'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              buttonLogoUrl: kioskUserSignInController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}