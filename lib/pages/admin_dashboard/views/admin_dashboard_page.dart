import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/admin_dashboard/controller/admin_dashboard_controller.dart';

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
      onConfirmed: () async => _handleNavigation(),
    );

    _dashboardController.initialise(
      onAlreadyRedirect: () async => _handleNavigation(),
    );

  }

  _handleNavigation() async {
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
