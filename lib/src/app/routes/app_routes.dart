// ---------------------------------------------------------------------------
// AppRoutes — named route paths used by GoRouter.
//
// Usage:  context.go(AppRoutes.home);
//
// These paths are a CONTRACT with the whole team. If you rename a path,
// update this file AND tell Persons B, C, D so they can update their
// navigation calls.
// ---------------------------------------------------------------------------

class AppRoutes {
  AppRoutes._();

  // --- Auth ---------------------------------------------------------------
  static const String login  = '/login';
  static const String signup = '/signup';

  // --- Student main tabs --------------------------------------------------
  static const String home       = '/home';
  static const String menu       = '/menu';
  static const String favourites = '/favs';
  static const String cart       = '/cart';

  // --- Other student screens ----------------------------------------------
  static const String profile = '/profile';
  static const String team    = '/team';

  // --- Vendor (Person C) --------------------------------------------------
  static const String vendorDashboard = '/vendor';
  static const String vendorLogin     = '/vendor/login';
  static const String vendorRegister  = '/vendor/register';
}
