import 'package:flutter/foundation.dart';

import '../../models/category_model.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/menu_repository.dart';

// ---------------------------------------------------------------------------
// HomeController — Manages data loading for the Home screen.
//
// This is a ChangeNotifier (provider state management, RULES.md Section 4).
// It loads bestsellers for the current campus and all categories.
//
// The controller is created via ChangeNotifierProxyProvider so that when the
// CampusController fires a change, HomeController.load() is automatically
// called with the new campusId — the screen never needs to trigger this.
//
// State model:
//   isLoading    → true while fetching; show skeleton boxes
//   error        → non-null if the fetch failed; show ErrorView + Retry
//   bestsellers  → list of available bestseller items
//   categories   → sorted list of all food categories
// ---------------------------------------------------------------------------

class HomeController extends ChangeNotifier {
  final MenuRepository _repo;

  HomeController(this._repo);

  // --- State ----------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MenuItemModel> _bestsellers = [];
  List<MenuItemModel> get bestsellers => _bestsellers;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // Tracks the campus we most recently loaded for (avoids redundant fetches).
  String? _loadedCampusId;

  // --- Loading --------------------------------------------------------------

  /// Load bestsellers and categories for [campusId].
  ///
  /// This is called automatically by [ChangeNotifierProxyProvider] whenever
  /// the campus changes, and also manually after an error (Retry button).
  Future<void> load(String campusId) async {
    // Skip if already loaded for this campus (prevents duplicate calls).
    if (_loadedCampusId == campusId && !_isLoading && _error == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Parallel fetches — categories are campus-independent but we always
      // reload them on campus change to stay consistent.
      final results = await Future.wait([
        _repo.getBestsellers(campusId),
        _repo.getCategories(),
      ]);

      _bestsellers = results[0] as List<MenuItemModel>;
      _categories = results[1] as List<CategoryModel>;
      _loadedCampusId = campusId;
      _error = null;
    } catch (e) {
      _error = 'Could not load items. Please check your connection.';
      debugPrint('[HomeController] load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Called by the Retry button in ErrorView.
  Future<void> retry(String campusId) {
    _loadedCampusId = null; // Force a real reload even for the same campus
    return load(campusId);
  }
}
