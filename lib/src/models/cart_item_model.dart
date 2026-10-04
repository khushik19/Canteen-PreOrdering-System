/// Minimal cart-side model. Coordinate the final shape of this with
/// Person A's menu_item_model (cooking time) and the shared order_model
/// before merge week.
class CartItemModel {
  final String id; // menu item id
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int cookingTimeMinutes; // from Person A's menu_item_model
  int quantity;
  bool isFavourite;

  CartItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.cookingTimeMinutes = 0,
    this.quantity = 1,
    this.isFavourite = false,
  });

  double get lineTotal => price * quantity;
}

/// A suggested add-on shown in "Complete Your Order" or "For You".
class RecommendationItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? label; // e.g. "♥ Liked", "↻ Ordered before"
  final bool isCombo;

  const RecommendationItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.label,
    this.isCombo = false,
  });
}