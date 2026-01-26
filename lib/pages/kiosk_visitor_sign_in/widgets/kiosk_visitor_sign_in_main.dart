import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';

class KioskVisitorSignInMain extends StatelessWidget {
  const KioskVisitorSignInMain({
    super.key,
    required this.kioskController,
    required this.maxBodyWidth,
  });

  final KioskVisitorSignInController kioskController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
           constraints: BoxConstraints(maxWidth: maxBodyWidth),
        )
      )
    );
  }
}