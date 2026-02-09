  import 'package:visitor_practise/core/models/site_item.dart';

/// Get site display name with ID prefix
  String resolveSiteHeading(SiteItem currentSite, [String fallback = 'Visitor Site']) {

    final id = currentSite.id.trim();
    final title = currentSite.title.trim();
    final baseTitle = title.isNotEmpty ? title : fallback;

    if (id.isEmpty) {
      return baseTitle.isNotEmpty ? baseTitle : fallback;
    }

    final hasIdPrefix = baseTitle.toLowerCase().startsWith(id.toLowerCase());
    return hasIdPrefix ? baseTitle : '$id - $baseTitle';
  }
