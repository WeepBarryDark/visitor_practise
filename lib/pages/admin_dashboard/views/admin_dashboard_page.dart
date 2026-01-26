import 'package:flutter/material.dart';
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
    _dashboardController = AdminDashboardController(
      onConfirmed: () async => _navigateKiosk(),
    );

    _dashboardController.initialise(
      onAlreadyRedirect: () async => _handleNavigation(),
    );

  }

  _handleNavigation() async {
  }

  Future<void> _navigateKiosk() async {
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);
    
    if (!_dashboardController.isCheckingInitialDashboard) {
      return const LoadingCircleInterface();
    }

    return BackgroundImageParent(
       customBackgroundUrl: _dashboardController.backgroundImageUrl!,
       mainWidget: AdminDashboardMain(adminDashboardController: _dashboardController, maxBodyWidth: maxBodyWidth)
    );
  }
}

