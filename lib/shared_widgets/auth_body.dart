import 'package:flutter/material.dart';


class AuthBody extends StatelessWidget {
  const AuthBody({
    super.key,
    this.siteTitle,
    required this.logoUrlTop,
    required this.logoUrlBottom,
    required this.menuContent,
  });

  final String? siteTitle;
  final String logoUrlTop;
  final String logoUrlBottom;
  final Widget menuContent;


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
            menuContent,

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