import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controller/admin_dashboard_controller.dart';

class VisitorRequirementFieldCard extends StatelessWidget {
  const VisitorRequirementFieldCard({
    super.key,
    required this.adminController,
  });

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {

    final tt = Theme.of(context).textTheme;

    return Card (
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Visitor Required Fields', style: tt.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Select which fields visitors must fill out when checking in',
              style: tt.bodySmall?.copyWith(color: AppTheme.slate600),
            ),
            const SizedBox(height: 16),
            //mandatory vsiitor inform--------------------------------
            CheckboxListTile(
              value: adminController.reqFullName,
              onChanged: null, // Name is always required, cannot be disabled
              title: const Text('Full name (required)'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqEmail,
              onChanged: null, // Email is always required, cannot be disabled
              title: const Text('Email address (required)'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            //mandatory vsiitor inform-----------------------------end
            //optional visitor inform---------------------------------
            CheckboxListTile(
              value: adminController.reqPhone,
              onChanged: (v) => adminController.setReqPhone(v),
              title: const Text('Phone number'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqWorkType,
              onChanged: (v) => adminController.setReqWorkType(v),
              title: const Text('Work type'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqCompany,
              onChanged: (v) => adminController.setReqCompany(v),
              title: const Text('Company name'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqAddress,
              onChanged: (v) => adminController.setReqAddress(v),
              title: const Text('Address'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqPersonVisiting,
              onChanged: (v) => adminController.setReqPersonVisiting(v),
              title: const Text('Person Visiting'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqSignInTime,
              onChanged: (v) => adminController.setReqSignTime(v),
              title: const Text('Sign in time'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: adminController.reqVisitorPhoto,
              onChanged: (v) => adminController.setReqVisitorPhoto(v),
              title: const Text('Visitor Photo'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            //optional visitor inform------------------------------end
            //Confirm button------------------------------------------
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {print('Generate preview button');},
              child: const Text('Preview Visitor Badge'),
            ),
          ],
        ),
      ),
    );
  }
}