// ---------------------------------------------------------------------------
// CategoryModel — Blueprint for a food category (e.g. Sandwiches, Maggi).
//
// Matches the Firestore schema in PROJECT_CONTEXT.md Section 6:
//   categories/{categoryId}: name, imageUrl, sortOrder
// ---------------------------------------------------------------------------

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sortOrder,
  });

  /// Create a CategoryModel from a map (Firestore doc or mock data).
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to a map for writing to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
    };
  }

  /// Create a copy with selected fields modified.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, sortOrder: $sortOrder)';
}
