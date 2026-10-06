class MenuItemModel {
  final String id;
  final String vendorId;
  final String campusId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category; // e.g., 'Meals', 'Snacks', 'Beverages', 'Desserts'
  final bool isAvailable;
  final int cookingTimeMinutes; // Person C manages this, Cart & Menu browse consume it
  final bool isVeg;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MenuItemModel({
    required this.id,
    required this.vendorId,
    required this.campusId,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.cookingTimeMinutes = 10,
    this.isVeg = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      vendorId: map['vendorId'] as String? ?? '',
      campusId: map['campusId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String? ?? 'General',
      isAvailable: map['isAvailable'] as bool? ?? true,
      cookingTimeMinutes: (map['cookingTimeMinutes'] as num?)?.toInt() ?? 10,
      isVeg: map['isVeg'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'campusId': campusId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'cookingTimeMinutes': cookingTimeMinutes,
      'isVeg': isVeg,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  MenuItemModel copyWith({
    String? vendorId,
    String? campusId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    int? cookingTimeMinutes,
    bool? isVeg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id,
      vendorId: vendorId ?? this.vendorId,
      campusId: campusId ?? this.campusId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      isVeg: isVeg ?? this.isVeg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
