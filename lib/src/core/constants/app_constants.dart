// ---------------------------------------------------------------------------
// AppConstants — campus list, Firestore collection names, and other app-wide
// constants that multiple team members rely on.
//
// Usage:  import 'package:canteen_crave/src/core/constants/app_constants.dart';
//
// If you change anything here, notify the team (Persons B, C, D) because
// they read campusId values and collection names from this file.
// ---------------------------------------------------------------------------

/// Represents one campus option in the dropdown.
class Campus {
  final String id;          // Firestore document key
  final String displayName; // shown in the UI

  const Campus({required this.id, required this.displayName});
}

class AppConstants {
  AppConstants._();

  // --- App info -----------------------------------------------------------
  static const String appName = 'Canteen Crave';

  // --- Campuses -----------------------------------------------------------
  static const List<Campus> campuses = [
    Campus(id: 'pimr_ug',   displayName: 'PIMR UG'),
    Campus(id: 'pimr_pg',   displayName: 'PIMR PG'),
    Campus(id: 'piemr',     displayName: 'PIEMR'),
    Campus(id: 'pimr_law',  displayName: 'PIMR Law'),
  ];

  /// The campus selected by default when the user opens the app for the first
  /// time (before they pick one). Index into [campuses].
  static const String defaultCampusId = 'pimr_ug';

  // --- Firestore collection names -----------------------------------------
  static const String usersCollection      = 'users';
  static const String categoriesCollection = 'categories';
  static const String menuItemsCollection  = 'menu_items';
  static const String ordersCollection     = 'orders';
  static const String flashSalesCollection = 'flash_sales';

  // --- Roles --------------------------------------------------------------
  static const String roleStudent = 'student';
  static const String roleVendor  = 'vendor';

  // --- Cooking time options (minutes) -------------------------------------
  static const List<int> cookingTimeOptions = [5, 10, 15, 20, 25];
}
