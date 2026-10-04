import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';

enum PickupMode { asap, scheduled }

/// Holds all Cart screen state. It's a plain ChangeNotifier so it drops
/// into Provider/Riverpod/Bloc later without rewriting the widgets.
class CartController extends ChangeNotifier {
  // Canteen operating window — single source of truth, shared by ASAP
  // resolution and the scheduled-pickup wheel so the two can never drift
  // out of sync with each other.
  static const int openingMinutes = 9 * 60; // 9:00 AM
  static const int closingMinutes = 17 * 60 + 20; // 5:20 PM

  final List<CartItemModel> items;
  PickupMode pickupMode = PickupMode.scheduled;
  // Defaults to opening time so OrderModel.pickupTime is well-defined even
  // if the student never touches the wheel (pickupMode now defaults to
  // Scheduled, not ASAP) — the wheel's own initState reads this same
  // value, so the UI and the order stay in sync from the first frame.
  TimeOfDay? scheduledTime = const TimeOfDay(hour: 9, minute: 0);

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

  int get _maxPrepMinutes => items.fold<int>(
        0,
        (max, item) => item.cookingTimeMinutes > max ? item.cookingTimeMinutes : max,
      );

  /// Earliest pickup minute-of-day (0–1439) the kitchen can realistically
  /// fulfil right now, clamped to canteen operating hours
  /// (9:00 AM – 5:20 PM). Returns null if there's no feasible slot left
  /// today (too close to or past closing). Used by ASAP resolution below.
  /// (The Scheduled wheel enforces operating hours structurally — its
  /// hour/minute option lists only ever contain valid values — so it
  /// doesn't need this real-clock-dependent check.)
  int? earliestFeasibleMinuteOfDay() {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final rawEarliest = nowMinutes + _maxPrepMinutes;
    final rounded = (rawEarliest / 15).ceil() * 15;
    final clamped = rounded < openingMinutes ? openingMinutes : rounded;
    if (clamped + 15 > closingMinutes) return null; // nothing feasible today
    return clamped;
  }

  /// Resolves the actual DateTime for an ASAP order, constrained to
  /// canteen operating hours — never a blind "now + prep" that could land
  /// before opening or after closing.
  DateTime resolveAsapPickupTime() {
    final now = DateTime.now();
    final minute = earliestFeasibleMinuteOfDay() ?? (closingMinutes - 15);
    return DateTime(now.year, now.month, now.day, minute ~/ 60, minute % 60);
  }
}