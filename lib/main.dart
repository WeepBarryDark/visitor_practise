import 'package:flutter/material.dart';

import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';


//theme
import 'package:visitor_practise/core/theme/app_theme.dart';
//pages
import 'package:visitor_practise/pages/auth/views/auth_page.dart';
import 'package:visitor_practise/pages/admin_dashboard/views/admin_dashboard_page.dart';
import 'package:visitor_practise/pages/new_site/view/new_site_page.dart';

void main() {
  runApp(const WorxVistor());
}

class WorxVistor extends StatelessWidget {
  const WorxVistor({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worx Visitor Kiosk',
      theme: AppTheme.lightTheme,

      //initial route - Splash Screen checks auth
      initialRoute: '/',

      routes: {
        '/': (context) => const AuthPage(),
        AppRoutes.dashboard: (context) => const AdminDashboardPage(),
        AppRoutes.newSite: (context) => const NewSitePage(),
      },
    );
  }
}


