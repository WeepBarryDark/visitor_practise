import 'package:flutter/material.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';
import 'package:visitor_practise/pages/admin_dashboard/controller/admin_dashboard_controller.dart';
import 'package:visitor_practise/pages/admin_dashboard/widgets/print_test_card.dart';
import 'package:visitor_practise/shared_widgets/label_value.dart';

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
          children: [
            Row(
              children: [
                //header ----------------------------------------------------------
                Expanded(child: Text('Printer Status', style: tt.titleMedium)),
                if (adminController.isConnectingPrinter)
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
            const SizedBox(height: 12),
            LabelValue('Initialized', adminController.isInitializedPrinter ? 'Yes' : 'No'),
            LabelValue('Printer', 'Print Name'),
            LabelValue('IP Address', 'Print IP Address'),
            
            //show retry button section when first connection fail----------------------------------------------
            if (adminController.showManualInput) ... [
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry Connection'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { print('show manual input');},
                      icon: Icon(
                        adminController.showManualInput ? Icons.close : Icons.edit,
                        size: 18,
                      ),
                      label: Text(adminController.showManualInput ? 'Cancel' : 'Manual IP'),
                    ),
                  ),
                ],
              ),
            ],
            //The manually add Printer Section----------------------------------------------
            if (adminController.showManualInput) ...[
              const SizedBox(height: 16),
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
                    Row(
                      children: [
                        Icon(
                          Icons.settings_ethernet,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Printer Manually',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.slate800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the IP address of your Brother printer (e.g., 192.168.1.100)',
                      style: TextStyle(fontSize: 13, color: AppTheme.slate700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      //controller: _ipController,
                      enabled: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Printer IP Address',
                        hintText: '192.168.1.100',
                        prefixIcon: const Icon(Icons.computer),
                        //errorText: _manualInputError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon( 
                      onPressed: () {print('submit data');},
                      icon: !adminController.isAddingManualPrinter
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
                          : const Icon(Icons.add, size: 18),
                      label: Text( adminController.isAddingManualPrinter ? 'Adding Printer...' : 'Add Printer',),
                    ),
                  ],
                ),
              )
            ],
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
            // Print badge toggle (always show) to decide auto print badge or not----------------------------------------------
            const SizedBox(height: 16),
            SwitchListTile(
              value: true,
              onChanged: adminController.allowPrintBadge,
              title: const Text('Auto-print visitor badges'),
              subtitle: const Text('Print badge when visitor signs in'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            PrintTestCard(adminController),
          ]
        )
      )
    );
  }
}