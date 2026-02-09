import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/navigation/main_scaffold.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/admin_dashboard_main.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/background_image_parent.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/loading_circle_interface.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

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

    // Wait for first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardController.initialise(
          onAlreadyRedirect:(nextRoute) async => _handleAutoNavigation(nextRoute),
          context: context,
        );
      }
    });
  }

  Future<void> _handleAutoNavigation(String nextRoute) async {
    try {
      Navigator.of(context).pushReplacementNamed(nextRoute);
    } catch (e) {
      if (!mounted) return;
      context.showError(
        "Offline or Server Unreachable. Check Internet Connection and restart this app. If it's not internet issue, please contact developer.",
        duration: const Duration(seconds: 5),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    return ListenableBuilder (
      listenable: _dashboardController,
      builder: (context, _) {
        if (_dashboardController.isCheckingInitialDashboard) {
          return const LoadingCircleInterface();
        }

        return AppShell( 
          title: 'Admin Dashboard',
          child:  BackgroundImageParent(
            backgroundBytes: _dashboardController.background!,
            mainWidget: AdminDashboardMain(adminDashboardController: _dashboardController, maxBodyWidth: maxBodyWidth)
          ),
        );
      },
    );
  }
}

