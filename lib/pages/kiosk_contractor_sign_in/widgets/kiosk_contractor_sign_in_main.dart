import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_contractor_sign_in/controllers/kiosk_contractor_sign_in_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';

class KioskContractorSignInMain extends StatelessWidget {
  const KioskContractorSignInMain({
    super.key,
    required this.kioskContractorSignInController,
    required this.maxBodyWidth,
  });

  final KioskContractorSignInController kioskContractorSignInController;
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
              topLogoBytes: kioskContractorSignInController.topLogo!,
              siteTitle: kioskContractorSignInController.getSiteTitle(),
              printReady: kioskContractorSignInController.isPrinterReady,
              supervisorName: kioskContractorSignInController.currentSite?.siteSupervisor.name,
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
                                key: ValueKey(kioskContractorSignInController.contractorUrl), // Force rebuild when URL changes
                                data: kioskContractorSignInController.contractorUrl,
                                version: QrVersions.auto,
                                size: 280,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                              SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.link, color: Theme.of(context).colorScheme.primary, size: 20,),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        kioskContractorSignInController.contractorUrl,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontFamily: 'monospace',
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Next Visitor Button - Return to kiosk dashboard for next visitor
                      Center(
                        child: SizedBox(
                          width: maxBodyWidth / 1.5,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.kioskDashboard,
                              (route) => false,  // Clear navigation stack
                            ),
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
              bottomLogoBytes: kioskContractorSignInController.bottomLogo!,
            ),
        ),
      ),
    );
  }
}