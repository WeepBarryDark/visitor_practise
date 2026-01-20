import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/auth/controller/auth_controller.dart';

class TabletAuthStatusBar extends StatelessWidget {
  const TabletAuthStatusBar({
    super.key,
    required this.controller,
    });

    final AuthController controller;

  @override
  Widget build(BuildContext context) {

    final bool isPolling = controller.isPolling;
    final bool hasError = controller.hasError;
    final bool isCheckingInitialAuth = controller.isCheckingInitialAuth;

    //first check or polling with spinner
    final bool showSpinner = isPolling || isCheckingInitialAuth;

    final Color backgroundColor = hasError
        ? AppTheme.statusBackgroundColor('error')
        : showSpinner
        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
        : AppTheme.statusBackgroundColor('success');

    final Color borderColor = hasError
        ? AppTheme.dangerColor.withValues(alpha: 0.3)
        : showSpinner
        ? AppTheme.primaryBlue.withValues(alpha: 0.3)
        : AppTheme.successColor.withValues(alpha: 0.3);

    final String message = isCheckingInitialAuth
    ? 'Checking if this tablet is already logged in...'
    : controller.statusMessage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          if (showSpinner)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),)
            )
          else
            Icon(
              hasError ? Icons.error_outline : Icons.check_circle_outline,
              color: hasError ? AppTheme.dangerColor : AppTheme.successColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slate800),
              )
            )
        ],
      ),
    );
  }
}