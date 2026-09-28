class TopSellingItem {
  final String itemId;
  final String name;
  final int quantitySold;
  final double totalRevenue;

  TopSellingItem({
    required this.itemId,
    required this.name,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory TopSellingItem.fromMap(Map<String, dynamic> map) {
    return TopSellingItem(
      itemId: map['itemId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantitySold: (map['quantitySold'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantitySold': quantitySold,
      'totalRevenue': totalRevenue,
    };
  }
}

class VendorReportModel {
  final String vendorId;
  final DateTime date;
  final double totalRevenue;
  final int totalOrdersCount;
  final int completedOrdersCount;
  final int cancelledOrdersCount;
  final double averagePrepTimeMinutes;
  final List<TopSellingItem> topSellingItems;
  final double onlinePaymentsAmount;
  final double cashPaymentsAmount;

  VendorReportModel({
    required this.vendorId,
    required this.date,
    this.totalRevenue = 0.0,
    this.totalOrdersCount = 0,
    this.completedOrdersCount = 0,
    this.cancelledOrdersCount = 0,
    this.averagePrepTimeMinutes = 12.0,
    this.topSellingItems = const [],
    this.onlinePaymentsAmount = 0.0,
    this.cashPaymentsAmount = 0.0,
  });

  factory VendorReportModel.fromOrders({
    required String vendorId,
    required DateTime date,
    required List<dynamic> orders, // OrderModel list
  }) {
    double revenue = 0.0;
    int completed = 0;
    int cancelled = 0;
    double online = 0.0;
    double cash = 0.0;
    final Map<String, _AggItem> itemMap = {};

    for (final order in orders) {
      final status = order.status.name as String;
      if (status == 'completed') {
        completed++;
        revenue += order.totalAmount as double;
        if (order.paymentStatus == 'paid' || order.paymentStatus == 'online') {
          online += order.totalAmount as double;
        } else {
          cash += order.totalAmount as double;
        }

        for (final item in order.items) {
          final existing = itemMap[item.itemId];
          if (existing == null) {
            itemMap[item.itemId] = _AggItem(
              name: item.name,
              qty: item.quantity,
              rev: item.price * item.quantity,
            );
          } else {
            existing.qty += item.quantity as int;
            existing.rev += (item.price * item.quantity) as double;
          }
        }
      } else if (status == 'cancelled') {
        cancelled++;
      }
    }

    final topList = itemMap.entries.map((e) {
      return TopSellingItem(
        itemId: e.key,
        name: e.value.name,
        quantitySold: e.value.qty,
        totalRevenue: e.value.rev,
      );
    }).toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return VendorReportModel(
      vendorId: vendorId,
      date: date,
      totalRevenue: revenue,
      totalOrdersCount: orders.length,
      completedOrdersCount: completed,
      cancelledOrdersCount: cancelled,
      topSellingItems: topList.take(5).toList(),
      onlinePaymentsAmount: online,
      cashPaymentsAmount: cash,
    );
  }
}

class _AggItem {
  String name;
  int qty;
  double rev;
  _AggItem({required this.name, required this.qty, required this.rev});
}
