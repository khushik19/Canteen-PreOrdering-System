enum FlashSaleStatus { active, claimed, expired }

class FlashSaleModel {
  final String id;
  final String orderId;
  final String itemId;
  final String itemName;
  final String? imageUrl;
  final double originalPrice;
  final int discountPercent;
  final String campusId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final FlashSaleStatus status;
  final String? claimedByUserId;

  FlashSaleModel({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    this.imageUrl,
    required this.originalPrice,
    required this.discountPercent,
    required this.campusId,
    required this.createdAt,
    required this.expiresAt,
    this.status = FlashSaleStatus.active,
    this.claimedByUserId,
  });

  double get discountedPrice =>
      originalPrice - (originalPrice * discountPercent / 100);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory FlashSaleModel.fromMap(Map<String, dynamic> map, String id) {
    return FlashSaleModel(
      id: id,
      orderId: map['orderId'] as String,
      itemId: map['itemId'] as String,
      itemName: map['itemName'] as String,
      imageUrl: map['imageUrl'] as String?,
      originalPrice: (map['originalPrice'] as num).toDouble(),
      discountPercent: map['discountPercent'] as int,
      campusId: map['campusId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      status: FlashSaleStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'active'),
        orElse: () => FlashSaleStatus.active,
      ),
      claimedByUserId: map['claimedByUserId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'itemId': itemId,
      'itemName': itemName,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'campusId': campusId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.name,
      'claimedByUserId': claimedByUserId,
    };
  }

  FlashSaleModel copyWith({
    FlashSaleStatus? status,
    String? claimedByUserId,
  }) {
    return FlashSaleModel(
      id: id,
      orderId: orderId,
      itemId: itemId,
      itemName: itemName,
      imageUrl: imageUrl,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      campusId: campusId,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: status ?? this.status,
      claimedByUserId: claimedByUserId ?? this.claimedByUserId,
    );
  }
}