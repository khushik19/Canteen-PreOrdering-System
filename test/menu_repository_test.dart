import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_crave/src/repositories/menu_repository.dart';

void main() {
  late MenuRepository repository;

  setUp(() {
    repository = MenuRepository();
  });

  test('MenuRepository returns 9 categories in sorted order', () async {
    final categories = await repository.getCategories();
    expect(categories.length, 9);
    expect(categories.first.id, 'sandwiches');
    expect(categories.last.id, 'combos');
  });

  test('MenuRepository returns bestsellers for pimr_ug', () async {
    final bestsellers = await repository.getBestsellers('pimr_ug');
    expect(bestsellers.isNotEmpty, true);
    for (final item in bestsellers) {
      expect(item.campusId, 'pimr_ug');
      expect(item.isBestseller, true);
      expect(item.isAvailable, true);
    }
  });

  test('MenuRepository returns campus items and filters by category', () async {
    final allUgItems = await repository.getItems('pimr_ug');
    expect(allUgItems.length, 18);

    final maggiItems = await repository.getItems('pimr_ug', categoryId: 'maggi');
    expect(maggiItems.length, 2);
    for (final item in maggiItems) {
      expect(item.categoryId, 'maggi');
    }
  });
}
