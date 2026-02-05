import 'package:flutter/material.dart';

import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';


//theme
import 'package:visitor_practise/core/theme/app_theme.dart';
//pages
import 'package:visitor_practise/pages/auth/views/auth_page.dart';
import 'package:visitor_practise/pages/admin_dashboard/views/admin_dashboard_page.dart';
import 'package:visitor_practise/pages/kiosk_deliveries/views/kiosk_deliveries_page.dart';
import 'package:visitor_practise/pages/kiosk_contractor_sign_in/views/kiosk_contractor_sign_in_page.dart';
import 'package:visitor_practise/pages/kiosk_visitor_badge_retrieve/views/kiosk_visitor_badge_retrieve_page.dart';
import 'package:visitor_practise/pages/kiosk_visitor_final_badge/views/kiosk_visitor_final_badge_page.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/views/kiosk_visitor_sign_in_page.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_out/views/kiosk_visitor_sign_out_page.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/views/kiosk_visitor_site_questions_page.dart';
import 'package:visitor_practise/pages/new_site/views/new_site_page.dart';

import 'package:visitor_practise/pages/new_site/views/new_site_page.dart';

import 'package:visitor_practise/pages/kiosk_dashboard/views/kiosk_dashboard_page.dart';

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

        AppRoutes.kioskDashboard: (context) => const KioskDashboardPage(),

        AppRoutes.kioskVisitorSignIn: (context) => const KioskVisitorSignInPage(),
        AppRoutes.kioskVisitorSignOut: (context) => const KioskVisitorSignOutPage(),
        AppRoutes.kioskDeliveries: (context) => const KioskDeliveriesPage(),
        AppRoutes.kioskContractorSignIn: (context) => const KioskContractorSignInPage(),
        AppRoutes.kioskVisitorBadgeRetrieve: (context) => const KioskVisitorBadgeRetrievePage(),

      },
    );
  }
}


