import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

class TabletAuthHeader extends StatelessWidget {
  const TabletAuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.qr_code_2, color: Colors.white, size:20),
        ),
        const SizedBox(width: 12,),
        Expanded(
          child: Text(
            'Kiosk Authentication',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          )
        ),
      ],
    );
  }
}