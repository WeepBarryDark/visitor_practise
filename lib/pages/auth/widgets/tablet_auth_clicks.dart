import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/auth/controllers/auth_controller.dart';

class TabletAuthClicks extends StatelessWidget {

// bottom section
// show "I have scanned the barcode"
// show "Re-scan QR code"
// show "Restart QR login"
  const TabletAuthClicks({
    super.key,
    required this.controller
  });

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final bool hasError = controller.hasError;
    final bool isPollingStarted = controller.isPollingStarted;

    return Column(
      children: [
        if (!isPollingStarted)
          FilledButton.icon(
            onPressed: controller.isCheckingInitialAuth ? null : controller.startPolling, // null the button will be disable
            icon: const Icon(Icons.done, size:20),
            label: Text(controller.isCheckingInitialAuth ? 'Checking login status...' : 'I have scanned the barcode',),
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            )
        else
          FilledButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white,),
            ),
            label: const Text('Waiting for approval...'),
            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          ),
        const SizedBox(height: 12),
        if (hasError) //once run into error, new button to reset 
          OutlinedButton.icon(
            onPressed: controller.regenerateLocalQr,  //remove all local storage, restart the app
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Restart QR Login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
              side: BorderSide(color: AppTheme.warningColor, width: 1.5),
              minimumSize: const Size(double.infinity, 48),
            ),
          )
      ],
    );
  }
}