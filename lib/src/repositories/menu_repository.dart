import '../datasources/mock/mock_menu_data.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';

// ---------------------------------------------------------------------------
// MenuRepository — The repository ("waiter") for categories and food items.
//
// Screens only talk to this class, never directly to mock data or Firestore.
// Right now, it returns data from MockMenuData with a 400ms simulated delay
// so loading spinners/skeletons can be tested. Later, we can swap in Firestore
// calls here without touching any of the UI screens.
// ---------------------------------------------------------------------------

class MenuRepository {
  /// Simulated network latency (400ms) for testing loading states.
  static const Duration _simulatedDelay = Duration(milliseconds: 400);

  /// Fetch all food categories sorted by sortOrder.
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(_simulatedDelay);
    final list = List<CategoryModel>.from(MockMenuData.categories);
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// Fetch bestseller items for the specified campus.
  /// Only available items marked as bestsellers are returned.
  Future<List<MenuItemModel>> getBestsellers(String campusId) async {
    await Future.delayed(_simulatedDelay);
    return MockMenuData.menuItems
        .where((item) =>
            item.campusId == campusId &&
            item.isBestseller &&
            item.isAvailable)
        .toList();
  }

  /// Fetch menu items for a campus, optionally filtered by category.
  Future<List<MenuItemModel>> getItems(
    String campusId, {
    String? categoryId,
  }) async {
    await Future.delayed(_simulatedDelay);
    return MockMenuData.menuItems.where((item) {
      final matchesCampus = item.campusId == campusId;
      final matchesCategory = categoryId == null || item.categoryId == categoryId;
      return matchesCampus && matchesCategory;
    }).toList();
  }
}
