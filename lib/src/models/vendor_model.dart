class VendorModel {
  final String id;
  final String canteenName;
  final String campusId;
  final String ownerName;
  final String email;
  final String phone;
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final double rating;
  final int totalOrders;
  final DateTime createdAt;

  VendorModel({
    required this.id,
    required this.canteenName,
    required this.campusId,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.isOpen = true,
    this.openingTime = '08:00 AM',
    this.closingTime = '08:00 PM',
    this.rating = 5.0,
    this.totalOrders = 0,
    required this.createdAt,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map, String id) {
    return VendorModel(
      id: id,
      canteenName: map['canteenName'] as String? ?? '',
      campusId: map['campusId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isOpen: map['isOpen'] as bool? ?? true,
      openingTime: map['openingTime'] as String? ?? '08:00 AM',
      closingTime: map['closingTime'] as String? ?? '08:00 PM',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canteenName': canteenName,
      'campusId': campusId,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'isOpen': isOpen,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'rating': rating,
      'totalOrders': totalOrders,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  VendorModel copyWith({
    String? canteenName,
    String? campusId,
    String? ownerName,
    String? email,
    String? phone,
    bool? isOpen,
    String? openingTime,
    String? closingTime,
    double? rating,
    int? totalOrders,
    DateTime? createdAt,
  }) {
    return VendorModel(
      id: id,
      canteenName: canteenName ?? this.canteenName,
      campusId: campusId ?? this.campusId,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
