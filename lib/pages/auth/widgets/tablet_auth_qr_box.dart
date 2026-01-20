import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/auth/controller/auth_controller.dart';

import 'package:qr_flutter/qr_flutter.dart';

class TabletAuthQrBox extends StatelessWidget {
  const TabletAuthQrBox({
    super.key,
    required this.controller,
  });
  
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final bool showLoading = controller.isCheckingInitialAuth || controller.qrUrl == null || controller.isPolling || controller.isPollingStarted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: 220,
        height: 220,
        child: Center(
          child: showLoading
            ? const CircularProgressIndicator()
            : QrImageView(
              data:controller.qrUrl!,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
        )
      )
    );
  }
}