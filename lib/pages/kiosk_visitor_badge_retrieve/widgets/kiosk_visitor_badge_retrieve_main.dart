import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_visitor_badge_retrieve/controllers/kiosk_visitor_badge_retrieve_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';

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
      alignment: AlignmentGeometry.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
              headLogoUrl: kioskVisitorBadgeRetrieveController.logoImageUrl, 
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Re-print Visitor Badge',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700,),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search for a signed-in visitor and re-print their badge.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600,),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Form - Select, Search
                    Form(
                      //key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search button first
                          FilledButton.icon(
                            onPressed: () {print('_showSignedInVisitorsList');},
                            icon: const Icon(Icons.search, size: 22),
                            label: const Text('Search Visitor'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          //Seleted visitor ID - Visitor ID field (read-only)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Visitor ID',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: kioskVisitorBadgeRetrieveController.visitorIdCtrl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Click "Search Visitor" to select',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Badge preview
                          if (kioskVisitorBadgeRetrieveController.badgeImageBytes != null) ...[
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
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 800),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(kioskVisitorBadgeRetrieveController.badgeImageBytes!, fit: BoxFit.contain,),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                  onPressed: kioskVisitorBadgeRetrieveController.submitting ? null : () => {print('jump to new site with all data')},
                                  child: kioskVisitorBadgeRetrieveController.submitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.print),
                                        SizedBox(width: 8),
                                        Text('Submit'),
                                      ],
                                    ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                  ],
                ),
              ),
              buttonLogoUrl: kioskVisitorBadgeRetrieveController.powerByLogoUrl,
            ),
        ),
      ),
    );
  }
}