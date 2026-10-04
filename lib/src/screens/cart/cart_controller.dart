import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';

enum PickupMode { asap, scheduled }

/// Holds all Cart screen state. It's a plain ChangeNotifier so it drops
/// into Provider/Riverpod/Bloc later without rewriting the widgets.
class CartController extends ChangeNotifier {
  final List<CartItemModel> items;
  PickupMode pickupMode = PickupMode.asap;
  TimeOfDay? scheduledTime;

  // TODO: replace with a real Smart Kitchen estimate from the backend
  // (current time + prep time + kitchen workload).
  int asapEstimateMinutes;

  CartController({List<CartItemModel>? initialItems, this.asapEstimateMinutes = 15})
      : items = initialItems ?? [];

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  bool get isEmpty => items.isEmpty;

  void increaseQuantity(String id) {
    final index = items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    final index = items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    if (items[index].quantity <= 1) {
      removeItem(id);
    } else {
      items[index].quantity--;
      notifyListeners();
    }
  }

  void toggleFavourite(String id) {
    final index = items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    items[index].isFavourite = !items[index].isFavourite;
    notifyListeners();
  }

  void removeItem(String id) {
    items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearCart() {
    items.clear();
    notifyListeners();
  }

  void addRecommendation(RecommendationItem rec) {
    final existing = items.where((i) => i.id == rec.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      items.add(CartItemModel(
        id: rec.id,
        name: rec.name,
        description: '',
        price: rec.price,
        imageUrl: rec.imageUrl,
      ));
    }
    notifyListeners();
  }

  void setPickupMode(PickupMode mode) {
    pickupMode = mode;
    notifyListeners();
  }

  void setScheduledTime(TimeOfDay time) {
    scheduledTime = time;
    pickupMode = PickupMode.scheduled;
    notifyListeners();
  }
}