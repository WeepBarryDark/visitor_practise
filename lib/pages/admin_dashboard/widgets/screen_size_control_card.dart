import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/admin_dashboard/controllers/admin_dashboard_controller.dart';

/// Screen Size Control Card
/// Allows admin to configure the kiosk display size (card width)
class ScreenSizeControlCard extends StatelessWidget {
  const ScreenSizeControlCard({
    super.key,
    required this.adminController,
  });

  final AdminDashboardController adminController;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Size Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.zoom_out_map,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kiosk Display Size',
                    textAlign: TextAlign.center,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Adjust the card width for your kiosk screen',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Segmented Button
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'compact',
                      label: Text('Narrow'),
                      icon: Icon(Icons.phone_android),
                    ),
                    ButtonSegment<String>(
                      value: 'medium',
                      label: Text('Normal'),
                      icon: Icon(Icons.tablet_android),
                    ),
                    ButtonSegment<String>(
                      value: 'large',
                      label: Text('Wide'),
                      icon: Icon(Icons.desktop_windows),
                    ),
                  ],
                  selected: {adminController.screenSize},
                  onSelectionChanged: (Set<String> newSelection) {
                    adminController.updateScreenSize(newSelection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.primaryContainer;
                        }
                        return colorScheme.surface;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.onPrimaryContainer;
                        }
                        return colorScheme.onSurface;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Size info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getSizeDescription(adminController.screenSize),
                        style: tt.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSizeDescription(String size) {
    switch (size) {
      case 'compact':
        return 'Narrow cards - for tablets';
      case 'medium':
        return 'Normal cards - recommended';
      case 'large':
        return 'Wide cards - for large displays';
      default:
        return 'Select a card width for kiosk display';
    }
  }
}
