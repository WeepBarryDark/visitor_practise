import 'package:flutter/material.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/admin_dashboard_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {

  late final AdminDashboardController _dashboardController;
  @override
  void initState() {
    super.initState();
    _dashboardController = AdminDashboardController();

    _dashboardController.initialise(
      onAlreadyRedirect:(nextRoute) async => _handleNavigationKiosk(nextRoute),
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
    
    if (!_dashboardController.isCheckingInitialDashboard) {
      return const LoadingCircleInterface();
    }

    return AnimatedBuilder(
      animation: _dashboardController,
      builder: (context, _) {
        if (_dashboardController.isCheckingInitialDashboard) {
          return const LoadingCircleInterface();
        }
          
      return AppShell( 
        title: 'Admin Dashboard',
        child:  BackgroundImageParent(
          webNotAsset: _dashboardController.useCustomBackground,
          customBackgroundUrl: _dashboardController.backgroundImage,
          mainWidget: AdminDashboardMain(adminDashboardController: _dashboardController, maxBodyWidth: maxBodyWidth)
        ),
      );
      },
    );
  }
}

