import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/printer_paper_type.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/searchable_dropdown_dialog.dart';

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
                  if(adminController.printerName.isNotEmpty && adminController.printerName != 'Not connected') ... [
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
                          Flexible(
                            child: Text(
                              'Model: ${adminController.printerName}',
                              style: TextStyle(fontSize: 11,fontWeight: FontWeight.w600,color: AppTheme.primaryBlue,),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${adminController.availablePaperTypes.length} options',
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
                  if (adminController.isLoadingPaperType)
                    // Loading Icon
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (adminController.availablePaperTypes.isEmpty)
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
                    //searchable dropdown
                    SearchableDropdownField<PrinterPaperType>(
                      value: adminController.selectedPaperType != null
                          ? adminController.availablePaperTypes.firstWhere(
                              (p) => p.code == adminController.selectedPaperType,
                              orElse: () => adminController.availablePaperTypes.first,
                            )
                          : null,
                      items: adminController.availablePaperTypes,
                      onChanged: (paperType) => adminController.selectThePaperType(paperType?.code),
                      dialogTitle: 'Select Paper Type',
                      dialogIcon: Icons.description,
                      placeholder: 'Select paper type',
                      icon: Icons.description,
                      searchHint: 'Search by paper code or description...',
                      emptyMessage: 'No paper types found',
                      emptyHint: 'Try adjusting your search',
                      itemName: (paperType) => paperType.fullDisplayName,
                      itemId: (paperType) => paperType.code,
                      searchMatcher: (paperType, query) {
                        final searchLower = query.toLowerCase();
                        return paperType.code.toLowerCase().contains(searchLower) ||
                               paperType.description.toLowerCase().contains(searchLower) ||
                               paperType.width.toLowerCase().contains(searchLower);
                      },
                      showClearButton: false,
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
                      onPressed: (adminController.isInitializedPrinter && adminController.selectedPaperType != null)
                        ? () => adminController.startTestPrint(context)
                        : null,
                      icon: adminController.isPrinting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2,))
                        : const Icon(Icons.print),
                      label: Text(adminController.isPrinting  ? 'Printing...' : 'Run Test Print'),
                    ),
                    // test print button-------------------------------end
                    const SizedBox(height: 16),
                    //Current selected Paper Type-------------------------
                    if (adminController.selectedPaperType != null) ...[
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
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current: ${adminController.selectedPaperType}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.slate700,
                                  fontWeight: FontWeight.w500,
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