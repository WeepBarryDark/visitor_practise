import 'package:flutter/material.dart';
import 'package:visitor_practise/pages/new_site/controllers/new_siter_controllder.dart';
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
            child: Image.asset(newSiteControllder.LogoImageUrl!),
            )
          ),
        ),

        //Search bar on top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SearchField(),
        ),

        //site count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: Text(
            newSiteControllder.searchQuery.isEmpty
              ? 'Total Sites: guest number'
              : 'Show search of search'
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
              onDeleted: () {
                print('Clear');
              }
            ),
          ),

        //Site List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 0,
            itemBuilder: (_, i) {
              final site = newSiteControllder.filtered[i];
              return SiteCard(
                site: site,
                onTap: () {
                  print("here go to dashboard with the site");
                },
              );
            }, 
            separatorBuilder: (_,_) => const SizedBox(height: 8,),
          ),
        )
      ],


    );
  }
}