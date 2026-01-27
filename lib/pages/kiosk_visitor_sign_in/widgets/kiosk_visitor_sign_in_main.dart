import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/kiosk_field.dart';

class KioskVisitorSignInMain extends StatelessWidget {
  const KioskVisitorSignInMain({
    super.key,
    required this.kioskVisitorSignInController,
    required this.maxBodyWidth,
  });

  final KioskVisitorSignInController kioskVisitorSignInController;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: KioskBody(
            headLogoUrl: kioskVisitorSignInController.logoImageUrl, 
            siteTitle: "test", 
            printReady: true, 
            supervisorName: "Barry Wang",
            menuContent: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(kioskVisitorSignInController.showFullName) ... [
                      KioskField(
                        controller: kioskVisitorSignInController.fullNameCtrl, 
                        title: 'Full Name', 
                        required: true, 
                        autofill: const [AutofillHints.name],
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Full name is required';
                            return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if(kioskVisitorSignInController.showEmail) ... [
                      KioskField(
                        controller: kioskVisitorSignInController.emailCtrl,
                        title: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        autofill: const [AutofillHints.email],
                        required: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (kioskVisitorSignInController.showPhone) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.phoneCtrl,
                        title: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        autofill: const [AutofillHints.telephoneNumber],
                        required: true,
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (kioskVisitorSignInController.showWorkType) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.workTypeCtrl,
                        title: 'Work Type',
                        required: true,
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return 'Work type is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (kioskVisitorSignInController.showCompany) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.companyCtrl,
                        title: 'Company',
                        required: true,
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Company is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (kioskVisitorSignInController.showAddress) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.addressCtrl,
                        title: 'Address',
                        required: true,
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Address is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    //-------------------------------- show contractor detail - selects 

                    //--------------------------------- show contracto detail - end
                    if (kioskVisitorSignInController.showSignInTime) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign In Time',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: kioskVisitorSignInController.signInTimeCtrl,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Sign In Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Device Sign time',
                            style: Theme.of(context).textTheme.bodySmall ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                    //---------------------------------------------------------Visitor Photo Section photo function
                    //---------------------------------------------------------Visitor Photo Section end
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context), // return to kiosk dashboard
                          label: const Text('Back'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: kioskVisitorSignInController.submitting ? null : () => { print('nothing')},
                          child: kioskVisitorSignInController.submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Next'),
                        ),
                      ],
                    ),
                  ]
                ),
              ),
            ),
            buttonLogoUrl: kioskVisitorSignInController.powerByLogoUrl,
          ),
        ),
      ),
    );
  }
}