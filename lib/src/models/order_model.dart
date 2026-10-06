import 'cart_item_model.dart';

/// Order status lifecycle. C's vendor dashboard writes transitions after
/// "placed"; D reads this for Profile/order history and Flash Sale
/// eligibility (unpicked orders).
///
/// IMPORTANT: this enum is a shared contract. Confirm these exact values
/// with Person C and Person D before merge week — renaming a value later
/// means touching three people's code.
enum OrderStatus {
  placed,
  accepted,
  rejected,
  expired,
  preparing,
  ready,
  completed,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double total;
  final DateTime placedAt;
  final DateTime pickupTime; // ASAP resolves to an actual DateTime at placement
  final bool isAsap;
  OrderStatus status;
  final DateTime requestExpiresAt;
  String? rejectionReason;
  String? paymentId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.placedAt,
    required this.pickupTime,
    required this.isAsap,
    this.status = OrderStatus.placed,
    required this.requestExpiresAt,
    this.rejectionReason,
    this.paymentId,
  });
}