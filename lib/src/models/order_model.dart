enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  completed,
  cancelled,
  uncollected,
}

class OrderItemModel {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final int cookingTimeMinutes;
  final String? imageUrl;

  OrderItemModel({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.cookingTimeMinutes = 10,
    this.imageUrl,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      itemId: map['itemId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      cookingTimeMinutes: (map['cookingTimeMinutes'] as num?)?.toInt() ?? 10,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'cookingTimeMinutes': cookingTimeMinutes,
      'imageUrl': imageUrl,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String vendorId;
  final String campusId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String paymentStatus; // 'paid', 'pending', 'cod'
  final String orderOtp;
  final DateTime? pickupEstimatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.userName = 'Student',
    this.userPhone = '',
    required this.vendorId,
    required this.campusId,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.placed,
    this.paymentStatus = 'paid',
    this.orderOtp = '1234',
    this.pickupEstimatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int get maxCookingTimeMinutes {
    if (items.isEmpty) return 10;
    return items.map((e) => e.cookingTimeMinutes).reduce((a, b) => a > b ? a : b);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItemModel.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();

    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Student',
      userPhone: map['userPhone'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      campusId: map['campusId'] as String? ?? '',
      items: itemsList,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'placed'),
        orElse: () => OrderStatus.placed,
      ),
      paymentStatus: map['paymentStatus'] as String? ?? 'paid',
      orderOtp: map['orderOtp'] as String? ?? '0000',
      pickupEstimatedAt: map['pickupEstimatedAt'] != null
          ? DateTime.tryParse(map['pickupEstimatedAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'vendorId': vendorId,
      'campusId': campusId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus,
      'orderOtp': orderOtp,
      'pickupEstimatedAt': pickupEstimatedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? paymentStatus,
    DateTime? pickupEstimatedAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      vendorId: vendorId,
      campusId: campusId,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderOtp: orderOtp,
      pickupEstimatedAt: pickupEstimatedAt ?? this.pickupEstimatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
