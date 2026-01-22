import 'package:flutter/material.dart';

import 'package:visitor_practise/core/theme/app_theme.dart';

import 'package:visitor_practise/pages/auth/controller/auth_controller.dart';

//sub-widget
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_clicks.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_header.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_instruction.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_status_bar.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_qr_box.dart';

class TabletAuthScaffold extends StatelessWidget {
  final AuthController controller;

  const TabletAuthScaffold({
    super.key,  //Constructors for public widgets should have a named 'key' parameter.
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      //container + decoration create a blue warp
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2), width: 1.5,),
      ),
      child: Column(
        children: [
          const TabletAuthHeader(),
          const SizedBox(height: 16),
          const TabletAuthInstruction(),
          const SizedBox(height: 16),
          TabletAuthQrBox(controller: controller,),
          const SizedBox(height: 16),
          TabletAuthStatusBar(controller: controller,),
          const SizedBox(height: 16),
          TabletAuthClicks(controller: controller,),
        ],
      ),
    );
  }
}