import 'package:flutter/foundation.dart';

import '../../models/category_model.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/menu_repository.dart';

// ---------------------------------------------------------------------------
// MenuPageController — State management for the Menu page.
//
// Responsibilities:
//   • Loads and holds food categories (sorted).
//   • Tracks the active category selection.
//   • Loads food items filtered by campusId and selectedCategoryId.
//   • Keeps the selected category intact when campus changes (updateCampus).
//   • Provides clean loading and error states for the item panel.
// ---------------------------------------------------------------------------

class MenuPageController extends ChangeNotifier {
  final MenuRepository _repository;
  String _campusId;

  List<CategoryModel> _categories = [];
  List<MenuItemModel> _items = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  MenuPageController(this._repository, {String campusId = ''})
      : _campusId = campusId;

  // --- Getters --------------------------------------------------------------

  List<CategoryModel> get categories => _categories;
  List<MenuItemModel> get items => _items;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get campusId => _campusId;

  CategoryModel? get selectedCategory {
    if (_selectedCategoryId == null || _categories.isEmpty) return null;
    return _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _categories.first,
    );
  }

  // --- Public actions -------------------------------------------------------

  /// Initial load: fetch categories, select initialCategoryId (or first),
  /// and load items for the active campus.
  Future<void> init(String campusId, {String? initialCategoryId}) async {
    _campusId = campusId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_categories.isEmpty) {
        _categories = await _repository.getCategories();
      }

      // Pick category: requested initial, or first in list
      if (_categories.isNotEmpty) {
        final hasRequested = initialCategoryId != null &&
            _categories.any((c) => c.id == initialCategoryId);
        _selectedCategoryId =
            hasRequested ? initialCategoryId : _categories.first.id;
      }

      await _fetchItems();
    } catch (e) {
      _errorMessage = 'Could not load menu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a category and load its items.
  Future<void> selectCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId && _items.isNotEmpty) return;
    _selectedCategoryId = categoryId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchItems();
    } catch (e) {
      _errorMessage = 'Could not load items: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by ChangeNotifierProxyProvider when campus selection changes.
  /// Keeps the currently selected category and reloads items for the new campus.
  Future<void> updateCampus(String newCampusId) async {
    if (_campusId == newCampusId && _categories.isNotEmpty) return;
    _campusId = newCampusId;

    if (_categories.isEmpty) {
      await init(newCampusId, initialCategoryId: _selectedCategoryId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchItems();
    } catch (e) {
      _errorMessage = 'Could not reload items for this campus: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retry the last failed operation.
  Future<void> retry() async {
    if (_categories.isEmpty) {
      await init(_campusId, initialCategoryId: _selectedCategoryId);
    } else {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      try {
        await _fetchItems();
      } catch (e) {
        _errorMessage = 'Could not load items: ${e.toString()}';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // --- Private helpers ------------------------------------------------------

  Future<void> _fetchItems() async {
    if (_selectedCategoryId == null || _campusId.isEmpty) {
      _items = [];
      return;
    }
    _items = await _repository.getItems(
      _campusId,
      categoryId: _selectedCategoryId,
    );
  }
}
