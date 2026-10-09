// ---------------------------------------------------------------------------
// AppRoutes - named route paths used by GoRouter.
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
  static const String splash         = '/splash';
  static const String login          = '/login';
  static const String signup         = '/signup';
  static const String forgotPassword = '/forgot-password';

  // --- Student main tabs --------------------------------------------------
  static const String home       = '/home';
  static const String menu       = '/menu';
  static const String favourites = '/favs';
  static const String cart       = '/cart';

  // --- Other student screens ----------------------------------------------
  static const String profile = '/profile';
  static const String team    = '/team';

  // --- Vendor (Person C will define sub-routes) ---------------------------
  static const String vendorDashboard = '/vendor';
}
