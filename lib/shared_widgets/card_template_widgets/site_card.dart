import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

class SiteCard extends StatelessWidget {
  const SiteCard({
    super.key,
    required this.site,
    required this.onTap,
  });

  final SiteItem site;
  final VoidCallback onTap;

 @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site title and active status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      site.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: site.active
                          ? AppTheme.statusBackgroundColor('success')
                          : AppTheme.statusBackgroundColor('inactive'),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      site.active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: site.active
                            ? AppTheme.successColor
                            : AppTheme.dangerColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.slate500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      site.address.isNotEmpty ? site.address : 'No address',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.slate600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Site Manager
              if (site.siteManager.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.slate500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Manager: ${site.siteManager}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // Site Supervisor
              if (site.siteSupervisor.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.supervisor_account_outlined,
                      size: 16,
                      color: AppTheme.slate500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Supervisor: site.siteSupervisor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}