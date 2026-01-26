import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/services/helper/logo_builder.dart';

class KioskBody extends StatelessWidget {
  const KioskBody({
    super.key,
    required this.headLogoUrl,
    this.headLogoBytes,
    required this.buttonLogoUrl,
    required this.siteTitle,
    required this.printReady,
    required this.menuContent,
    this.supervisorName,
    this.helpText,
    this.footerAction, //return to admin dashboard

  });

  final String headLogoUrl;
  final Uint8List? headLogoBytes;
  final String buttonLogoUrl;
  final String siteTitle;
  final bool printReady;
  final Widget menuContent;
  final String? supervisorName;
  final String? helpText;
  final Widget? footerAction;

  @override
  Widget build(BuildContext context) {

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final topLogo = LogoBuilder(headLogoUrl, 56, bytes: headLogoBytes);
    final bottomLogo = LogoBuilder(buttonLogoUrl, 36);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 5,  //shadow effect 0 1-2 4-6 8-15 16+
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //top logo and print indictor 
            Row(
              children: [
                Icon(
                  printReady ? Icons.print : Icons.print_disabled,
                  color: printReady ? AppTheme.successColor : Colors.white,
                  size: 20,
                ),
                Spacer(),
                // Top logo
                if (topLogo != null) Center(child: topLogo),
                const SizedBox(height: 14),
                Spacer(),
              ],
            ),
            // Site header
            Text(
              siteTitle,
              textAlign: TextAlign.center,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            //help text if applicable
            if (helpText != null && helpText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  helpText!,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.tertiary),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 24),
            //------------------------------------------button Icon goes
            menuContent,
            //end----------------------------------------button Icon goes
            //site supervisor
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (supervisorName != null && supervisorName!.isNotEmpty)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.7,),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Text(
                        "Site Supervisor: ${supervisorName!}",
                        style: tt.bodyMedium?.copyWith(color: cs.tertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                //Logo + footer action
                SizedBox(
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (bottomLogo != null)
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: bottomLogo,
                          ),
                        ),
                      ),
                    if (footerAction != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: footerAction!,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}