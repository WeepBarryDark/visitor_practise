import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/contact_detail.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/kiosk_field.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/searchable_dropdown_dialog.dart';

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
            topLogoBytes: kioskVisitorSignInController.topLogo!,
            siteTitle: kioskVisitorSignInController.getSiteTitle(),
            printReady: kioskVisitorSignInController.isPrinterReady,
            supervisorName: kioskVisitorSignInController.currentSite?.siteSupervisor.name,
            menuContent: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Full Name - always required
                    if (kioskVisitorSignInController.reqFullName) ...[
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
                    ],
                    const SizedBox(height: 16),
                    // Email - always required
                    if (kioskVisitorSignInController.reqEmail) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.emailCtrl,
                        title: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        autofill: const [AutofillHints.email],
                        required: true,
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (kioskVisitorSignInController.reqPhone) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.phoneCtrl,
                        title: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        autofill: const [AutofillHints.telephoneNumber],
                        required: kioskVisitorSignInController.reqPhone,
                        validator: (v) {
                          if (!kioskVisitorSignInController.reqPhone) return null;
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (kioskVisitorSignInController.reqWorkType) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.workTypeCtrl,
                        title: 'Work Type',
                        required: kioskVisitorSignInController.reqWorkType,
                        validator: (v) {
                          if (!kioskVisitorSignInController.reqWorkType) return null;
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return 'Work type is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (kioskVisitorSignInController.reqCompany) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.companyCtrl,
                        title: 'Company',
                        required: kioskVisitorSignInController.reqCompany,
                        validator: (v) {
                          if (!kioskVisitorSignInController.reqCompany) return null;
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Company is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (kioskVisitorSignInController.reqAddress) ...[
                      KioskField(
                        controller: kioskVisitorSignInController.addressCtrl,
                        title: 'Address',
                        required: kioskVisitorSignInController.reqAddress,
                        validator: (v) {
                          if (!kioskVisitorSignInController.reqAddress) return null;
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return 'Address is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    //-------------------------------- Contact Detail Selection - always shown
                    if (kioskVisitorSignInController.reqPersonVisiting) ...[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Person Visiting', style: Theme.of(context).textTheme.titleSmall,),
                                const SizedBox(width: 4),
                                const Text('*', style: TextStyle(color: Colors.red, fontSize: 16),),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (kioskVisitorSignInController.isLoadingContacts)
                              const Center(child: CircularProgressIndicator())
                            else if (kioskVisitorSignInController.availableContacts.isEmpty)
                              const Text(
                                'No contacts available. Please contact administrator.',
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              InkWell(
                                onTap: () async {
                                  final selected = await showDialog<ContactDetail>(
                                    context: context,
                                    builder: (context) => SearchableDropdownDialog<ContactDetail>(
                                      items: kioskVisitorSignInController.availableContacts,
                                      title: 'Select Contact',
                                      searchMatcher: (contact, query) =>
                                          contact.name.toLowerCase().contains(query) ||
                                          contact.email.toLowerCase().contains(query),
                                      itemId: (contact) => contact.id,
                                      itemName: (contact) => contact.name,
                                      itemSubtitle: (contact) => contact.email,
                                    ),
                                  );
                                  if (selected != null) {
                                    kioskVisitorSignInController.selectContact(selected);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_outline),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          kioskVisitorSignInController.selectedContact?.name ?? 'Select a contact',
                                          style: TextStyle(
                                            color: kioskVisitorSignInController.selectedContact != null
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              'Select who you are visiting',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                    //--------------------------------- Contact Detail Selection end
                    //-------------------------------------------------------------------------------contact select

                    //--------------------------------- Sign In Time
                    if (kioskVisitorSignInController.reqSignInTime) ...[
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
                    //---------------------------------------------------------Visitor Photo Section
                    if (kioskVisitorSignInController.reqVisitorPhoto) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Visitor Photo', style: Theme.of(context).textTheme.titleSmall,),
                              const SizedBox(width: 4),
                              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16),),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => kioskVisitorSignInController.captureVisitorPhoto(context),
                            icon: Icon(kioskVisitorSignInController.hasPhoto ? Icons.check_circle : Icons.camera_alt),
                            label: Text(kioskVisitorSignInController.hasPhoto ? 'Retake Photo' : 'Take Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kioskVisitorSignInController.hasPhoto
                                  ? Colors.green
                                  : null,
                              foregroundColor: kioskVisitorSignInController.hasPhoto
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                          if (kioskVisitorSignInController.hasPhoto) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '✓ Photo Taken',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            'Photo will be stored for records (not shown on badge)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                    //---------------------------------------------------------Visitor Photo Section end
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 12.0,
                      children: [
                        const SizedBox(width: double.infinity),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: kioskVisitorSignInController.submitting
                                  ? null
                                  : () async {
                                      final success = await kioskVisitorSignInController.submitSignIn(context);
                                      if (success && context.mounted) {
                                        final visitorData = kioskVisitorSignInController.buildVisitorData();
                                        if (visitorData != null) {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.kioskVisitorSiteQuestions,
                                            arguments: {
                                              'visitorData': visitorData,
                                              'signInController': kioskVisitorSignInController,
                                            },
                                          );
                                        }
                                      }
                                    },
                              icon: kioskVisitorSignInController.submitting
                                  ? const SizedBox( child: CircularProgressIndicator(strokeWidth: 2),)
                                  : const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]
                ),
              ),
            ),
            bottomLogoBytes: kioskVisitorSignInController.bottomLogo!,
          ),
        ),
      ),
    );
  }
}