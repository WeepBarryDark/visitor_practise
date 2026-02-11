import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/controllers/kiosk_visitor_final_badge_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

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
              topLogoBytes: kioskVisitorFinalBadgeController.topLogo!,
              siteTitle: kioskVisitorFinalBadgeController.getSiteTitle(),
              printReady: kioskVisitorFinalBadgeController.isPrinterReady,
              supervisorName: kioskVisitorFinalBadgeController.visitorData?.contactDetailName,
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
                          child: kioskVisitorFinalBadgeController.badgeImageBytes != null
                              ? Image.memory(
                                  kioskVisitorFinalBadgeController.badgeImageBytes!,
                                  fit: BoxFit.contain,
                                )
                              : const Center(
                                  child: Text('Badge image not available'),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Print Progress Display (only show if printing is enabled)
                    if (kioskVisitorFinalBadgeController.reqPrint) ...[
                      _buildPrintProgress(context, kioskVisitorFinalBadgeController.printProgress),
                      const SizedBox(height: 16),
                    ],

                    //Button, you can only click it when print is done
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: !kioskVisitorFinalBadgeController.isPrintComplete
                            ? null
                            : () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.kioskDashboard,
                                  (route) => false,
                                );
                              },
                        icon: !kioskVisitorFinalBadgeController.isPrintComplete
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
                          !kioskVisitorFinalBadgeController.isPrintComplete
                              ? 'Please wait...'
                              : 'Return to Kiosk',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              bottomLogoBytes: kioskVisitorFinalBadgeController.bottomLogo!,
            ),
        ),
      ),
    );
  }

  Widget _buildPrintProgress(BuildContext context, PrintProgress progress) {
    IconData icon;
    String text;
    Color color;

    switch (progress.status) {
      case PrintStatus.idle:
        icon = Icons.print_outlined;
        text = 'Preparing to print...';
        color = Colors.grey;
        break;
      case PrintStatus.connecting:
        icon = Icons.bluetooth_searching;
        text = 'Connecting to printer...';
        color = Colors.blue;
        break;
      case PrintStatus.sending:
        icon = Icons.upload;
        text = 'Sending badge to printer...';
        color = Colors.orange;
        break;
      case PrintStatus.receiving:
        icon = Icons.download;
        text = 'Receiving printer response...';
        color = Colors.lightBlue;
        break;
      case PrintStatus.queued:
        icon = Icons.queue;
        text = 'Print job queued...';
        color = Colors.amber;
        break;
      case PrintStatus.printing:
        icon = Icons.print;
        text = 'Printing badge...';
        color = Colors.purple;
        break;
      case PrintStatus.completed:
        icon = Icons.check_circle;
        text = 'Badge printed successfully!';
        color = Colors.green;
        break;
      case PrintStatus.failed:
        icon = Icons.error_outline;
        text = progress.message ?? 'Print failed';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (progress.status.isInProgress)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}