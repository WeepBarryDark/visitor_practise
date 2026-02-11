import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_visitor_badge_retrieve/controllers/kiosk_visitor_badge_retrieve_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/kiosk_field.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/searchable_dropdown_dialog.dart';
import 'package:visitor_practise/shared_widgets/qr_scanner_dialog.dart';

class KioskVisitorBadgeRetrieveMain extends StatelessWidget {
  const KioskVisitorBadgeRetrieveMain({
    super.key,
    required this.kioskVisitorBadgeRetrieveController,
    required this.maxBodyWidth,
  });

  final KioskVisitorBadgeRetrieveController kioskVisitorBadgeRetrieveController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
            topLogoBytes: kioskVisitorBadgeRetrieveController.topLogo!,
            siteTitle: kioskVisitorBadgeRetrieveController.getSiteTitle(),
            printReady: kioskVisitorBadgeRetrieveController.isPrinterReady,
            supervisorName: kioskVisitorBadgeRetrieveController.currentSite?.siteSupervisor.name,
            menuContent: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // QR Code Scanner Button
                  FilledButton.icon(
                    onPressed: () async {
                      final scannedId = await showDialog<String>(
                        context: context,
                        builder: (context) => const QRScannerDialog(),
                      );
                      if (scannedId != null && context.mounted) {
                        await kioskVisitorBadgeRetrieveController.lookupVisitorById(scannedId, context);
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 28),
                    label: const Text('Scan Visitor Badge'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Select from signed-in visitors
                  OutlinedButton.icon(
                    onPressed: kioskVisitorBadgeRetrieveController.isLoadingVisitors
                        ? null
                        : () async {
                            if (kioskVisitorBadgeRetrieveController.signedInVisitors.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No signed-in visitors found'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              return;
                            }

                            final selected = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => SearchableDropdownDialog<Map<String, dynamic>>(
                                title: 'Select Visitor for Badge Reprint',
                                icon: Icons.person_search,
                                items: kioskVisitorBadgeRetrieveController.signedInVisitors,
                                searchHint: 'Search by name, ID, or email...',
                                emptyMessage: 'No visitors found',
                                searchMatcher: (visitor, query) {
                                  final name = visitor['display_name']?.toString().toLowerCase() ?? '';
                                  final id = visitor['visitor_id']?.toString().toLowerCase() ?? '';
                                  final email = visitor['email']?.toString().toLowerCase() ?? '';
                                  return name.contains(query) || id.contains(query) || email.contains(query);
                                },
                                itemId: (visitor) => visitor['visitor_id']?.toString() ?? '',
                                itemName: (visitor) => visitor['display_name']?.toString() ?? 'Unnamed',
                                itemSubtitle: (visitor) => visitor['display_info']?.toString(),
                              ),
                            );

                            if (selected != null && context.mounted) {
                              await kioskVisitorBadgeRetrieveController.selectVisitor(selected, context);
                            }
                          },
                    icon: kioskVisitorBadgeRetrieveController.isLoadingVisitors
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.list, size: 24),
                    label: Text(
                      kioskVisitorBadgeRetrieveController.isLoadingVisitors
                          ? 'Loading...'
                          : 'Select from Signed-In Visitors',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with "OR" text
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 20),

                  // Manual Visitor ID input
                  KioskField(
                    controller: kioskVisitorBadgeRetrieveController.visitorIdCtrl,
                    title: 'Visitor ID',
                    helpText: 'Enter VIS code from badge',
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return 'Visitor ID is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Lookup button for manual input
                  OutlinedButton.icon(
                    onPressed: () {
                      kioskVisitorBadgeRetrieveController.lookupVisitorById(
                        kioskVisitorBadgeRetrieveController.visitorIdCtrl.text,
                        context,
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Look Up Visitor'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badge preview
                  if (kioskVisitorBadgeRetrieveController.badgePreviewBytes != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Badge Preview',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (kioskVisitorBadgeRetrieveController.isGeneratingBadge)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            )
                          else
                            Container(
                              constraints: const BoxConstraints(maxHeight: 800),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  kioskVisitorBadgeRetrieveController.badgePreviewBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Button group - Wrap for responsive layout
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: kioskVisitorBadgeRetrieveController.isPrinting ||
                                  kioskVisitorBadgeRetrieveController.selectedVisitor == null ||
                                  kioskVisitorBadgeRetrieveController.badgePreviewBytes == null ||
                                  !kioskVisitorBadgeRetrieveController.isPrinterReady
                            ? null
                            : () => kioskVisitorBadgeRetrieveController.reprintBadge(context),
                        icon: kioskVisitorBadgeRetrieveController.isPrinting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.print),
                        label: const Text('Reprint Badge'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottomLogoBytes: kioskVisitorBadgeRetrieveController.bottomLogo!,
          ),
        ),
      ),
    );
  }
}
