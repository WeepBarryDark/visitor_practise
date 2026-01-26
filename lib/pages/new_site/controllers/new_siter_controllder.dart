import 'package:visitor_practise/core/models/site_item.dart';

class NewSiterControllder {

  bool _isCheckingInitialSite = true;
  bool get isCheckingInitialSite => _isCheckingInitialSite;

  List<SiteItem> _allSites = [];
  List<SiteItem> get allSites => _allSites;

  //TODO
  bool _useCustomBackground = false;
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String LogoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String searchQuery ='';

    Future<void> initialise ({
    required Future<void> Function() onAlreadyRedirect,
  }) async {
    //Get background image 
    backgroundImageUrl = _useCustomBackground
      ? "https://storage.worxsafety.com.au/site/public/7/60dbb67c245b3_bg-masthead.jpg"
      : 'lib/assets/images/worx_inductions_cover.jpg';
  }

  List<SiteItem> get filtered {
    Iterable<SiteItem> items = _allSites;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.address.toLowerCase().contains(q) ||
          e.siteManager.toLowerCase().contains(q) ||
          e.siteSupervisor.toLowerCase().contains(q));
    }

    return items.toList(growable: false);
  }

}
