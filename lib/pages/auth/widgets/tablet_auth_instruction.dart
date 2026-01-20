import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

class TabletAuthInstruction extends StatelessWidget {
  const TabletAuthInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scan this QR code with a device already logged into Worx Safety,'
              'then click "I have scanned the barcode".',
              style: TextStyle(fontSize: 14, color: AppTheme.slate700, height: 1.5),
            )
          ),
        ],
      ),
    );
  }
}