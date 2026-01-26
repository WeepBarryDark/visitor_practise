class KioskDashboardController {

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial; 

  bool _useCustomBackground = false;
  String backgroundImageUrl = "lib/assets/images/worx_inductions_cover.jpg";

  bool _useCustomLogo = true;
  String logoImageUrl = "lib/assets/images/WorxSafety_Logo_NoShadow.png";

  String powerByLogoUrl = "lib/assets/images/Worx_PoweredBy_Logo_Mono.png";
}
