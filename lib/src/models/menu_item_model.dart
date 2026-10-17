// ---------------------------------------------------------------------------
// MenuItemModel — Blueprint for a food item on the menu.
//
// Matches the Firestore schema in PROJECT_CONTEXT.md Section 6:
//   menu_items/{itemId}:
//     name, description, price (rupees), imageUrl,
//     categoryId, campusId, cookingTimeMinutes (5 | 10 | 15 | 20 | 25),
//     isAvailable, isBestseller, isVeg
// ---------------------------------------------------------------------------

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price; // In Indian Rupees (₹)
  final String imageUrl;
  final String categoryId;
  final String campusId;
  final int cookingTimeMinutes; // 5, 10, 15, 20, or 25
  final bool isAvailable;
  final bool isBestseller;
  final bool isVeg;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.campusId,
    required this.cookingTimeMinutes,
    required this.isAvailable,
    required this.isBestseller,
    required this.isVeg,
  });

  /// Create a MenuItemModel from a map (Firestore doc or mock data).
  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      campusId: map['campusId'] as String? ?? '',
      cookingTimeMinutes: (map['cookingTimeMinutes'] as num?)?.toInt() ?? 10,
      isAvailable: map['isAvailable'] as bool? ?? true,
      isBestseller: map['isBestseller'] as bool? ?? false,
      isVeg: map['isVeg'] as bool? ?? true,
    );
  }

  /// Convert to a map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'campusId': campusId,
      'cookingTimeMinutes': cookingTimeMinutes,
      'isAvailable': isAvailable,
      'isBestseller': isBestseller,
      'isVeg': isVeg,
    };
  }

  /// Create a copy with selected fields modified.
  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    String? campusId,
    int? cookingTimeMinutes,
    bool? isAvailable,
    bool? isBestseller,
    bool? isVeg,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      campusId: campusId ?? this.campusId,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      isBestseller: isBestseller ?? this.isBestseller,
      isVeg: isVeg ?? this.isVeg,
    );
  }

  @override
  String toString() =>
      'MenuItemModel(id: $id, name: $name, price: ₹$price, campusId: $campusId, available: $isAvailable)';
}
