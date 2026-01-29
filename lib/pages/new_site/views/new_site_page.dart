import 'package:flutter/material.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/new_site/controllers/new_siter_controllder.dart';
import 'package:visitor_practise/pages/new_site/widgets/new_site_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class NewSitePage extends StatefulWidget {
  const NewSitePage({super.key});
  @override
  State<NewSitePage> createState() => _NewSitePageState();
}

class _NewSitePageState extends State<NewSitePage> {
  late final NewSiterControllder _newSiteController;

  @override
  void initState() {
    super.initState();
    _newSiteController = NewSiterControllder(); 
    //Step 1 check condition, if jump to kiosk, as before unexpected jump out
    _newSiteController.initialise(
      onAlreadyRedirect: (nextRoute) async => _handleNavigationKiosk(nextRoute),
    );
  }

  Future<void> _handleNavigationKiosk(String nextRoute) async {
    final nav = Navigator.of(context);
    final messagerWindow = ScaffoldMessenger.of(context);

    try {
      nav.pushReplacementNamed(nextRoute);
    } catch (e) {
      if (!mounted) return;
      messagerWindow.showSnackBar(
        const SnackBar(
          content: Text(
            "Offline or Server Unreachable. Check Internet Connection and restart this app. If it's not internet issue, please contact developer.",
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    return AnimatedBuilder(
        animation: _newSiteController,
        builder: (context, _) {
          if (_newSiteController.isCheckingInitialSite) {
            return const LoadingCircleInterface();
          }
          
          return AppShell(
            title: 'Sites List',
            child: BackgroundImageParent(
              webNotAsset: _newSiteController.useCustomBackground,
              customBackgroundUrl: _newSiteController.backgroundImage,
              mainWidget: NewSiteMain(
                newSiteControllder: _newSiteController,
                maxBodyWidth: maxBodyWidth,
              ),
            ),
          );
        },
      );
  }
}