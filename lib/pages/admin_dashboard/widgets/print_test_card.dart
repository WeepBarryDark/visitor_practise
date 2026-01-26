import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/paper_type.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';

class PrintTestCard extends StatelessWidget {
  const PrintTestCard(this.adminController, {super.key});

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    //inherit from previous level column
    return Column(
      children: [
        // Only show when printer is connected
        if (adminController.isInitializedPrinter) ... [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.statusBackgroundColor('info'),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              )
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header -------------------------------------------
                  Row(
                    children: [
                      Icon(Icons.description, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Paper Type',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,color: AppTheme.slate800,),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'REQUIRED',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Header -----------------------------------------end
                  const SizedBox(height: 8),
                  // Printer Model infor--------------------------------
                  if(adminController.printerModel.isNotEmpty) ... [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.print, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            'Model: ${adminController.printerModel}',
                            style: TextStyle(fontSize: 11,fontWeight: FontWeight.w600,color: AppTheme.primaryBlue,),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              //'${c.availablePaperTypes.length} options',
                              'Paper Length Options',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                  // Printer Model infor-----------------------------end
                  const SizedBox(height: 8),
                  // Select label paper section ------------------------
                  Text(
                    'Select the type of label paper installed in your printer',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                  ),
                  const SizedBox(height: 12),
                  if (!adminController.isLoadingPaperType)
                    // Loading Icon
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (!adminController.availablePaperTypes.isEmpty)
                    // No paper types available
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.statusBackgroundColor('warning'),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 20,),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No paper types available for this printer model',
                              style: TextStyle(fontSize: 12, color: AppTheme.slate700,),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    //dropdown box
                    DropdownButtonFormField<String>(
                      initialValue: adminController.selectedPaperType,
                      decoration: InputDecoration(
                        labelText: 'Select Paper Type',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.print),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: adminController.selectedPaperType == null ? 'Please select a paper type' : null,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A', child: Text('Apple')),
                        DropdownMenuItem(value: 'B', child: Text('Banana')),
                      ], 
                      onChanged: adminController.selectThePaperType
                    ),
                    // Select label paper section ---------------------end
                    const SizedBox(height: 8),
                    // paper type warning - reqiored or double check------
                    if(adminController.selectedPaperType == null) ... [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusBackgroundColor('warning'),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.warningColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, size: 16, color: AppTheme.warningColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Paper type selection is required before printing',
                              style: TextStyle(fontSize: 12, color: AppTheme.warningColor, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                    ),
                    ] else ... [
                      Text(
                        'Please always double check the paper type, as it may be selected wrong',
                        style: TextStyle(fontSize: 12, color: AppTheme.warningColor),
                      )
                    ],
                    // paper type warning - reqiored or double check---end
                    const SizedBox(height: 8),
                    // test print button----------------------------------
                    OutlinedButton.icon(
                      onPressed: (adminController.isInitializedPrinter) ? adminController.startTestPrint : null,
                      icon: adminController.isPrinting 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2,))
                        : const Icon(Icons.print),
                      label: Text(adminController.isPrinting  ? 'Printing...' : 'Run Test Print'),
                    ),
                    // test print button-------------------------------end
                    //show hint - you can only run test once per paper----
                    const SizedBox(height: 8),
                    if (adminController.hasTestPrinted) ... [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Test print completed. Change paper type to run test print again.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    //show hint - you can only run test once per paper-end
                    const SizedBox(height: 8),
                    //Current selected Paper Type-------------------------
                    if (adminController.selectedPaperType == null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.slate200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppTheme.slate600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current: printer paper type here',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.slate700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    //Current selected Paper Type----------------------end
                ],
            ),
          )
        ]
      ],
    );
  }
}