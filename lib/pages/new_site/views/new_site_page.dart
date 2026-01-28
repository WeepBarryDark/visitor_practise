import 'package:flutter/material.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/new_site/controllers/new_siter_controllder.dart';
import 'package:visitor_practise/pages/new_site/widgets/new_site_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/search_field.dart';

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

    if (!_newSiteController.isCheckingInitialSite) {
      return const LoadingCircleInterface();
    }

    return AppShell(
      title: 'Sites List',
      child: BackgroundImageParent(
       customBackgroundUrl: _newSiteController.backgroundImageUrl,
       mainWidget: NewSiteMain(newSiteControllder: _newSiteController,maxBodyWidth:maxBodyWidth)
      ),
    );
  }
}