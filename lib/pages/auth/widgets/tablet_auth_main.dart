import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/auth/controllers/auth_controller.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_clicks.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_header.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_instruction.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_status_bar.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_qr_box.dart';


class TabletAuthMain extends StatelessWidget {
  const TabletAuthMain({
    super.key,
    this.siteTitle,
    required this.logoUrlTop,
    required this.logoUrlBottom,
    required this.authController,
  });

  final String? siteTitle;
  final String logoUrlTop;
  final String logoUrlBottom;
  final AuthController authController;


  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Top Logo (Worx Safety Logo)
            Center(
              child: FittedBox(
                  fit:BoxFit.contain,
                  child: Image.asset(logoUrlTop),
                )
            ),
            const SizedBox(height: 14),

            // Site Title
            if (siteTitle != null && siteTitle?.isNotEmpty == true)
              Text(
                siteTitle!,
                textAlign: TextAlign.center,
                style: tt.titleLarge?.copyWith(fontWeight:  FontWeight.w800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16,),

            // log in actually functions
            Container(
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
                  TabletAuthQrBox(controller: authController,),
                  const SizedBox(height: 16),
                  TabletAuthStatusBar(controller: authController,),
                  const SizedBox(height: 16),
                  TabletAuthClicks(controller: authController,),
                ],
              ),
            ),

            const SizedBox(height: 24,),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 36,
                child: FittedBox(
                  fit:BoxFit.contain,
                  child: Image.asset(logoUrlBottom),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}