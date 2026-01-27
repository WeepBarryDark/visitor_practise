import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_out/controllers/kiosk_visitor_sign_out_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/kiosk_field.dart';

class KioskVisitorSignOutMain extends StatelessWidget {
 const KioskVisitorSignOutMain({
    super.key,
    required this.kioskVisitorSignOutController,
    required this.maxBodyWidth,
  });

  final KioskVisitorSignOutController kioskVisitorSignOutController;
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
              headLogoUrl: kioskVisitorSignOutController.logoImageUrl, 
              siteTitle: "test", 
              printReady: true, 
              supervisorName: "Barry Wang",
              menuContent: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // QR Code Scanner Button
                    FilledButton.icon(
                      onPressed: () => { print("_openQRScanner") },
                      icon: const Icon(Icons.qr_code_scanner, size: 28),
                      label: const Text('Scan Visitor Badge'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                     const SizedBox(height: 24),
                    // Select from sign in visitors
                    OutlinedButton.icon(
                      onPressed: () => { print("_openQRScanner") },
                      icon: const Icon(Icons.list, size: 24),
                      label: const Text('Select from Signed-In Visitors'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    //---------------------------------------divider
                    // Divider with "OR" text
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Text(
                            'OR ENTER MANUALLY',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
          
                    //----------------------------------------site question end
                    const SizedBox(height: 20),
                    // Visitor ID Field (auto-filled from QR scan)
                    KioskField(
                      controller: kioskVisitorSignOutController.visitorIDCtl,
                      title: 'Visitor ID',
                      helpText: 'Scan QR code or enter manually',
                      validator: (v) {
                        final text = (v ?? '').trim();
                        if (text.isEmpty) return 'Visitor ID is required';
                        return null;
                      },
                    ),

                    // Show scanned status
                    if (kioskVisitorSignOutController.scannedFromQR) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.statusBackgroundColor('success'),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.successColor.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Badge scanned successfully',
                                style: TextStyle(
                                  color: AppTheme.slate800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    //One share all Kiosk button group
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: const Text('Back'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: kioskVisitorSignOutController.submitting ? null : () => {print('jump to new site with all data')},
                          child: kioskVisitorSignOutController.submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buttonLogoUrl: kioskVisitorSignOutController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}