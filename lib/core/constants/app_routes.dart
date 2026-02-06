class AppRoutes {
  //AppRoutes._(); // Prevents instantiation

  static const String auth= '/';
  static const String adminDashboard ='/admin-dashboard'; //admin adshboard
  static const String newSite = '/new-site';//select another site

  static const String kioskDashboard = '/visitor-kiosk'; //entry point of visitor kiosk

  //visitor sign in option
  static const String kioskVisitorSignIn = '/visitor-sign-in'; 
  static const String kioskVisitorSignOut = '/visitor-sign-out';
  static const String kioskDeliveries = '/delivery';
  static const String kioskContractorSignIn = '/user-contractor-in';
  static const String kioskVisitorBadgeRetrieve = '/badge-retrieve'; //reprint badge for print issue or uploaded user from server not kiosk
}