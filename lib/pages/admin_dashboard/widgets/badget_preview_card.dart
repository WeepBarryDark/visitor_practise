import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';

class BadgetPreviewCard extends StatelessWidget {
  const BadgetPreviewCard({
    super.key,
    required this.adminController,
  });

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Visitor Badge Preview', style: tt.titleMedium),
            const SizedBox(height: 16,),
            // Preview Image (actual print output)-------------------
            if(adminController.previewImageBytes != null)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant, width: 2),
                    ),
                    child: Image.memory(adminController.previewImageBytes!, fit: BoxFit.contain),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Preview Image (actual print output)----------------end
            const SizedBox(height: 16,),
            //Notification setting-----------------------------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //header
                  Text('Notification Settings', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  //Delivery notification
                  Text(
                    'Delivery - Notify Site Supervisor',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  CheckboxListTile(
                      value: adminController.notifyDeliverySms,
                      onChanged: (v) => adminController.setNotifyDeliverySms(v),
                      title: const Text('SMS text'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                  ),
                  CheckboxListTile(
                      value: adminController.notifyDeliveryEmail,
                      onChanged: (v) => adminController.setNotifyDeliveryEmail(v),
                      title: const Text('Email'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                  ),
                  //Only if required people visiting
                  if (adminController.reqPersonVisiting) ... [
                    const SizedBox(height: 8),
                    Text(
                        'Person Visiting',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600,),
                    ),
                    CheckboxListTile(
                      value: adminController.notifyPersonVisitingSms,
                      onChanged: (v) => adminController.setNotifyPersonVisitingSms(v),
                      title: const Text('SMS text'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                    CheckboxListTile(
                      value: adminController.notifyPersonVisitingEmail,
                      onChanged: (v) => adminController.setNotifyPersonVisitorEmail(v),
                      title: const Text('Email'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    //Only if required people visiting-------------------------end
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            //Go to Kiosk Model Button------------------------------------
            FilledButton.icon(
              onPressed: () {print('go to kiosk');}, 
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),),
            ),
          ],
        ),
      ),
    );
  }
}