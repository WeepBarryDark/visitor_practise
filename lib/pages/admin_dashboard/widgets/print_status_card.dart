import 'package:another_brother/printer_info.dart' as brother;
import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/print_test_card.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/label_value.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/searchable_dropdown_dialog.dart';

class PrintStatusCard extends StatelessWidget {
  const PrintStatusCard({
    super.key,
    required this.adminController,
  });

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    //final cs = widget.controller;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Printer Setup', style: tt.titleMedium),
            //IOS allows internet connection only, android and windows allow both internet and USB
            const SizedBox(height: 16),
              SwitchListTile(
                value: adminController.reqPrint,
                onChanged: (v) => adminController.setReqPrint(v, context: context),
                title: const Text('Auto-print visitor badges'),
                subtitle: const Text('Print badge when visitor signs in'),
                contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            if ((adminController.platformName == "ios" || adminController.platformName == "android" || adminController.platformName == "windows") && adminController.reqPrint) ... [
              Row(
                children: [
                  //header ----------------------------------------------------------
                  Expanded(child: Text('Printer Status', style: tt.titleMedium)),
                  // Print badge toggle (always show) to decide auto print badge or not----------------------------------------------
                  if (adminController.isInitializingdPrinter)
                    // Still connecting - show loading indicator 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connecting...',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else if (adminController.isInitializedPrinter)
                    Text(
                      '● Connected',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  else
                    // Connection failed
                    Text(
                      '○ Not Connected',
                      style: TextStyle(
                        color: AppTheme.slate400,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              LabelValue('Initialized', adminController.isInitializedPrinter ? 'Yes' : 'No'),
              LabelValue('Printer', adminController.printerName),
              LabelValue('IP Address', adminController.printerIp),
              const SizedBox(height: 16),
              // Connection type selection
              Text(
                'Connection Method',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.slate800,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'model',
                      label: Text('By Model'),
                      icon: Icon(Icons.print),
                    ),
                    ButtonSegment<String>(
                      value: 'ip',
                      label: Text('By IP'),
                      icon: Icon(Icons.lan),
                    ),
                  ],
                  selected: {adminController.printerConnectionType},
                  onSelectionChanged: (Set<String> selection) {
                    adminController.setPrinterConnectionType(selection.first);
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Show content based on connection type
              if (adminController.printerConnectionType == 'model') ...[
                // Model selection with background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.statusBackgroundColor('info'),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Select your Brother printer model',
                        style: TextStyle(fontSize: 13, color: AppTheme.slate700),
                      ),
                      const SizedBox(height: 12),
                      SearchableDropdownField<brother.Model>(
                        value: adminController.selectedPrinterModel,
                        items: AdminDashboardController.supportedPrinterModels,
                        onChanged: (model) => adminController.selectPrinterModel(model),
                        dialogTitle: 'Select Printer Model',
                        dialogIcon: Icons.print,
                        placeholder: 'Select printer model',
                        icon: Icons.print,
                        searchHint: 'Search by model name...',
                        emptyMessage: 'No printer models found',
                        emptyHint: 'Try adjusting your search',
                        itemName: (model) => model.getName(),
                        itemId: (model) => model.getId().toString(),
                        searchMatcher: (model, query) => model.getName().toLowerCase().contains(query),
                        showClearButton: false,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: adminController.selectedPrinterModel == null ? null : () {
                          // TODO: Implement connect by model
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Connect'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // IP address input
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.statusBackgroundColor('info'),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter the IP address of your Brother printer',
                        style: TextStyle(fontSize: 13, color: AppTheme.slate700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: adminController.printerIpCtrl,
                        enabled: !adminController.isAddingManualPrinter,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Printer IP Address',
                          hintText: '192.168.1.100',
                          prefixIcon: const Icon(Icons.computer),
                          errorText: adminController.printerIpError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: adminController.isAddingManualPrinter ? null : () {
                          // TODO: Implement connect by IP
                        },
                        icon: adminController.isAddingManualPrinter
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.link, size: 18),
                        label: Text(adminController.isAddingManualPrinter ? 'Connecting...' : 'Connect'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              //all warning--------------------------------------------------------------------------
              if(adminController.isInitializedPrinter) ... [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.statusBackgroundColor('warning'),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No Printer Found',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.slate800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No Brother printers were found on the network. '
                        'Please check:\n'
                        '• Printer is powered on and ready\n'
                        '• Printer and device are on same WiFi network\n'
                        '• Printer IP address is accessible\n'
                        '• WiFi network allows device communication\n\n'
                        'Try using "Manual IP" to add your printer directly.',
                        style: TextStyle(
                          fontSize: 13,
                          overflow: TextOverflow.ellipsis,
                          color: AppTheme.slate700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              PrintTestCard(adminController),
            ]
          ]
        )
      )
    );
  }
}