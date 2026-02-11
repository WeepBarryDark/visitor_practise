import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/printer_progress.dart';
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
    final hasSubmissionError = !kioskVisitorFinalBadgeController.isSubmitting &&
        !kioskVisitorFinalBadgeController.isSubmitted &&
        kioskVisitorFinalBadgeController.errorMessage != null;

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
                    _getTitle(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // If submission error, show error message only
                  if (hasSubmissionError) ...[
                    _buildErrorMessage(context, kioskVisitorFinalBadgeController.errorMessage!),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Show badge image only after generation
                    if (kioskVisitorFinalBadgeController.badgeImageBytes != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 800),
                            child: Image.memory(
                              kioskVisitorFinalBadgeController.badgeImageBytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Step 1: Submission Status
                    _buildStepStatus(
                      context,
                      step: 1,
                      title: 'Submit Sign-In',
                      isActive: kioskVisitorFinalBadgeController.isSubmitting,
                      isComplete: kioskVisitorFinalBadgeController.isSubmitted,
                    ),
                    const SizedBox(height: 12),

                    // Step 2: Badge Generation Status (only show if submission succeeded)
                    if (kioskVisitorFinalBadgeController.isSubmitted ||
                        kioskVisitorFinalBadgeController.isGeneratingBadge ||
                        kioskVisitorFinalBadgeController.badgeImageBytes != null) ...[
                      _buildStepStatus(
                        context,
                        step: 2,
                        title: 'Generate Badge',
                        isActive: kioskVisitorFinalBadgeController.isGeneratingBadge,
                        isComplete: kioskVisitorFinalBadgeController.badgeImageBytes != null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Step 3: Print Status (only show if printing is enabled and badge is generated)
                    if (kioskVisitorFinalBadgeController.reqPrint &&
                        kioskVisitorFinalBadgeController.badgeImageBytes != null) ...[
                      _buildPrintProgress(context, kioskVisitorFinalBadgeController.printProgress),
                      const SizedBox(height: 16),

                      // Retry button for print
                      if (kioskVisitorFinalBadgeController.printProgress.status == PrintStatus.failed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: () => kioskVisitorFinalBadgeController.retryPrint(context),
                              icon: const Icon(Icons.print),
                              label: const Text('Retry Print'),
                            ),
                          ),
                        ),
                    ],
                  ],

                  // Return button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: !_canReturn()
                          ? null
                          : () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.kioskDashboard,
                                (route) => false,
                              );
                            },
                      icon: _isProcessing()
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                              ),
                            )
                          : const Icon(Icons.home),
                      label: Text(_getButtonText()),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomLogoBytes: kioskVisitorFinalBadgeController.bottomLogo!,
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (kioskVisitorFinalBadgeController.isSubmitting) {
      return 'Submitting Sign-In...';
    }
    if (kioskVisitorFinalBadgeController.isGeneratingBadge) {
      return 'Generating Badge...';
    }
    if (kioskVisitorFinalBadgeController.errorMessage != null &&
        !kioskVisitorFinalBadgeController.isSubmitted) {
      return 'Sign-In Failed';
    }
    if (kioskVisitorFinalBadgeController.badgeImageBytes != null) {
      return 'Your Visitor Badge';
    }
    return 'Processing...';
  }

  bool _isProcessing() {
    return kioskVisitorFinalBadgeController.isSubmitting ||
        kioskVisitorFinalBadgeController.isGeneratingBadge ||
        (kioskVisitorFinalBadgeController.reqPrint &&
            kioskVisitorFinalBadgeController.badgeImageBytes != null &&
            !kioskVisitorFinalBadgeController.isPrintComplete);
  }

  bool _canReturn() {
    // Can return if:
    // - Submission failed (allow going back)
    // - Or all processing is complete
    final submissionFailed = !kioskVisitorFinalBadgeController.isSubmitting &&
        !kioskVisitorFinalBadgeController.isSubmitted &&
        kioskVisitorFinalBadgeController.errorMessage != null;

    if (submissionFailed) return true;

    // If printing is required, must wait for print to complete
    if (kioskVisitorFinalBadgeController.reqPrint) {
      return kioskVisitorFinalBadgeController.isPrintComplete;
    }

    // If no printing, can return after badge is generated
    return kioskVisitorFinalBadgeController.badgeImageBytes != null;
  }

  String _getButtonText() {
    if (kioskVisitorFinalBadgeController.isSubmitting) {
      return 'Submitting...';
    }
    if (kioskVisitorFinalBadgeController.isGeneratingBadge) {
      return 'Generating Badge...';
    }
    if (kioskVisitorFinalBadgeController.reqPrint &&
        kioskVisitorFinalBadgeController.badgeImageBytes != null &&
        !kioskVisitorFinalBadgeController.isPrintComplete) {
      return 'Printing Badge...';
    }
    return 'Return to Kiosk';
  }

  Widget _buildErrorMessage(BuildContext context, String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sign-In Submission Failed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepStatus(
    BuildContext context, {
    required int step,
    required String title,
    required bool isActive,
    required bool isComplete,
  }) {
    IconData icon;
    Color color;
    String statusText;

    if (isComplete) {
      icon = Icons.check_circle;
      color = Colors.green;
      statusText = 'Complete';
    } else if (isActive) {
      icon = Icons.sync;
      color = Colors.blue;
      statusText = 'In Progress...';
    } else {
      icon = Icons.hourglass_empty;
      color = Colors.grey;
      statusText = 'Waiting...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (isActive)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $step: $title',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.1),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintProgress(BuildContext context, PrintProgress progress) {
    IconData icon;
    String statusText;
    Color color;

    switch (progress.status) {
      case PrintStatus.idle:
        icon = Icons.print_outlined;
        statusText = 'Waiting...';
        color = Colors.grey;
        break;
      case PrintStatus.connecting:
        icon = Icons.bluetooth_searching;
        statusText = 'Connecting to printer...';
        color = Colors.blue;
        break;
      case PrintStatus.sending:
        icon = Icons.upload;
        statusText = 'Sending to printer...';
        color = Colors.orange;
        break;
      case PrintStatus.receiving:
        icon = Icons.download;
        statusText = 'Receiving response...';
        color = Colors.lightBlue;
        break;
      case PrintStatus.queued:
        icon = Icons.queue;
        statusText = 'Print job queued...';
        color = Colors.amber;
        break;
      case PrintStatus.printing:
        icon = Icons.print;
        statusText = 'Printing...';
        color = Colors.purple;
        break;
      case PrintStatus.completed:
        icon = Icons.check_circle;
        statusText = 'Complete';
        color = Colors.green;
        break;
      case PrintStatus.failed:
        icon = Icons.error_outline;
        statusText = progress.message ?? 'Print failed';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (progress.status.isInProgress)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3: Print Badge',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.1),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
