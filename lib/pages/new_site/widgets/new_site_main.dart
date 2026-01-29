import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/pages/new_site/controllers/new_siter_controllder.dart';
import 'package:visitor_practise/services/helper/logo_builder.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/shared_widgets/field_input_widgets/search_field.dart';
import 'package:visitor_practise/shared_widgets/card_template_widgets/site_card.dart';

class NewSiteMain extends StatelessWidget {
  const NewSiteMain({
    super.key,
    required this.newSiteControllder,
    required this.maxBodyWidth,
  });

  final NewSiterControllder newSiteControllder;
  final double maxBodyWidth;

  Future<void> confirmSiteSelection(BuildContext context, SiteItem site) async {
    await SecureStorageService.saveSelectedSite(jsonEncode(site.toJson()));

    if (!context.mounted) return; // Flutter 3.7+ 支持
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          ),
          child: Center(
            child: FittedBox(
            fit:BoxFit.contain,
            child: newSiteControllder.useCustomLogo
              ? LogoBuilder(newSiteControllder.logoImageUrl, 48)
              : Image.asset(newSiteControllder.logoImageUrl, height: 48),
            )
          ),
        ),

        //Search bar on top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SearchField(
            controller:newSiteControllder.searchCtrl,
            onChanged: newSiteControllder.updateSearch,
          ),
        ),

        //site count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              newSiteControllder.searchQuery.isEmpty
                  ? 'Total Sites: ${newSiteControllder.allSites.length}'
                  : 'Showing ${newSiteControllder.filtered.length} of ${newSiteControllder.allSites.length} sites',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Search Chips 
        if (newSiteControllder.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Chip(
              label: Text(
                'Search: ${newSiteControllder.searchQuery}',
                overflow: TextOverflow.ellipsis,
              ),
              onDeleted: newSiteControllder.clearSearch,
            ),
          ),

        //Site List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            itemCount: newSiteControllder.filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final site = newSiteControllder.filtered[i];
              return SiteCard(
                site: site,
                onTap: () => confirmSiteSelection(context,site),
              );
            },
          ),
        )
      ],
    );
  }
}