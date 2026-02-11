import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/pages/kiosk_visitor_site_questions/controllers/kiosk_visitor_site_questions_controller.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/kiosk_body.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

class KioskVisitorSiteQuestionsMain extends StatelessWidget {
  const KioskVisitorSiteQuestionsMain({
    super.key,
    required this.kioskVisitorSiteQuestionsController,
    required this.maxBodyWidth,
  });

  final KioskVisitorSiteQuestionsController kioskVisitorSiteQuestionsController;
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
              topLogoBytes: kioskVisitorSiteQuestionsController.topLogo!,
              siteTitle: kioskVisitorSiteQuestionsController.getSiteTitle(),
              printReady: kioskVisitorSiteQuestionsController.isPrinterReady,
              supervisorName: kioskVisitorSiteQuestionsController.visitorData?.contactDetailName,
              menuContent: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Please answer the following before completing sign in.', style: Theme.of(context).textTheme.titleMedium,),
                    const SizedBox(height: 16),
                    //---------------------------------------site questions rendering
                    if (kioskVisitorSiteQuestionsController.isLoadingQuestions)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (kioskVisitorSiteQuestionsController.questions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No questions available'),
                        ),
                      )
                    else
                      ...kioskVisitorSiteQuestionsController.questions.map((question) {
                        final answer = kioskVisitorSiteQuestionsController.getAnswer(question.id);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question.text,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ' *',
                                        style: TextStyle(color: Colors.red, fontSize: 18),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                RadioGroup<bool>(
                                  groupValue: answer ?? false,
                                  onChanged: (value) {
                                    if (value != null) {
                                      kioskVisitorSiteQuestionsController.setAnswer(
                                        question.id,
                                        value,
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: const Text('Yes'),
                                          value: true,
                                          toggleable: false,
                                          activeColor: AppTheme.successColor,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<bool>(
                                          title: const Text('No'),
                                          value: false,
                                          toggleable: false,
                                          activeColor: Colors.red,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    // Validation message
                    if (kioskVisitorSiteQuestionsController.allQuestionsAnswered &&
                        !kioskVisitorSiteQuestionsController.allAnswersYes)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'All questions must be answered "Yes" to proceed',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    //----------------------------------------site questions end
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: const Text('Back'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: !kioskVisitorSiteQuestionsController.allAnswersYes
                              ? null
                              : () {
                                  final success = kioskVisitorSiteQuestionsController.validateAndProceed(context);
                                  if (success && context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.kioskVisitorFinalBadge,
                                      arguments: {
                                        'siteQuestionsController': kioskVisitorSiteQuestionsController,
                                      },
                                    );
                                  }
                                },
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottomLogoBytes: kioskVisitorSiteQuestionsController.bottomLogo!,
            ),
        ),
      ),
    );
  }
}