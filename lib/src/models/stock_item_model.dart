class StockItemModel {
  final String id;
  final String vendorId;
  final String name;
  final String category; // e.g., 'Snacks', 'Beverages', 'Chocolates'
  final double price;
  final int quantity;
  final int lowStockThreshold;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime updatedAt;

  StockItemModel({
    required this.id,
    required this.vendorId,
    required this.name,
    this.category = 'Packaged Snacks',
    required this.price,
    this.quantity = 0,
    this.lowStockThreshold = 10,
    this.isAvailable = true,
    this.imageUrl,
    required this.updatedAt,
  });

  bool get isLowStock => quantity <= lowStockThreshold && quantity > 0;
  bool get isOutOfStock => quantity <= 0 || !isAvailable;

  factory StockItemModel.fromMap(Map<String, dynamic> map, String id) {
    return StockItemModel(
      id: id,
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Packaged Snacks',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isAvailable: map['isAvailable'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StockItemModel copyWith({
    String? vendorId,
    String? name,
    String? category,
    double? price,
    int? quantity,
    int? lowStockThreshold,
    bool? isAvailable,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return StockItemModel(
      id: id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
