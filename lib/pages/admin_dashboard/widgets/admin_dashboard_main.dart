import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/admin_dashboard/controller/admin_dashboard_controller.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/badget_preview_card.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/kiosk_admin_password_card.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/print_status_card.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/site_information_card.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/visitor_requirement_field_card.dart';

class AdminDashboardMain extends StatelessWidget {
  const AdminDashboardMain({
    super.key,
    required this.adminDashboardController,
    required this.maxBodyWidth,
    });

  final AdminDashboardController adminDashboardController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    
    return AnimatedBuilder(
      animation: adminDashboardController, 
      builder: (context, _) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBodyWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SiteInformationCard(adminController: adminDashboardController),
                  const SizedBox(height: 16),
                  KioskAdminPasswordCard(adminController: adminDashboardController),
                  const SizedBox(height: 16),
                  PrintStatusCard(adminController: adminDashboardController),
                  const SizedBox(height: 16),
                  VisitorRequirementFieldCard(adminController: adminDashboardController),
                  const SizedBox(height: 16),
                  BadgetPreviewCard(adminController: adminDashboardController),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}