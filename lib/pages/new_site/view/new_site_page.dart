import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/new_site/controller/new_siter_controllder.dart';
import 'package:visitor_practise/pages/new_site/widget/new_site_main.dart';
import 'package:visitor_practise/shared_widgets/background_image_level.dart';
import 'package:visitor_practise/shared_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/search_field.dart';

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
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);
    final isMedium = maxBodyWidth >= AppBreakpoints.md;
    final isLarge = maxBodyWidth >= AppBreakpoints.lg;
    
    if (!_newSiteController.isCheckingInitialSite) {
      return const LoadingCircleInterface();
    }

    return BackgroundImageLevel(
       customBackgroundUrl: _newSiteController.backgroundImageUrl!,
       mainWidget: NewSiteMain(newSiteControllder: _newSiteController,maxBodyWidth:maxBodyWidth)
    );
  }
}