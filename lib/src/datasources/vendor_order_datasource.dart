import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class VendorOrderDatasource {
  FirebaseFirestore? _firestore;

  VendorOrderDatasource({FirebaseFirestore? firestore}) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      _firestore = null;
    }
  }

  static final List<OrderModel> _demoOrders = [
    OrderModel(
      id: 'ORD_9410',
      userId: 'student_101',
      userName: 'Aditi Sharma',
      userPhone: '9876543210',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      items: [
        OrderItemModel(itemId: 'item_1', name: 'Paneer Butter Masala Combo', price: 130.0, quantity: 1, cookingTimeMinutes: 15),
        OrderItemModel(itemId: 'item_4', name: 'Iced Cold Coffee', price: 50.0, quantity: 1, cookingTimeMinutes: 5),
      ],
      totalAmount: 180.0,
      status: OrderStatus.placed, // New incoming order!
      paymentStatus: 'paid',
      orderOtp: '4821',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    OrderModel(
      id: 'ORD_9408',
      userId: 'student_102',
      userName: 'Rahul Verma',
      userPhone: '9811223344',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      items: [
        OrderItemModel(itemId: 'item_2', name: 'Crispy Veg Burger', price: 70.0, quantity: 2, cookingTimeMinutes: 10),
      ],
      totalAmount: 140.0,
      status: OrderStatus.preparing, // In kitchen cooking!
      paymentStatus: 'paid',
      orderOtp: '7192',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    OrderModel(
      id: 'ORD_9405',
      userId: 'student_103',
      userName: 'Sneha Patel',
      userPhone: '9988776655',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      items: [
        OrderItemModel(itemId: 'item_3', name: 'Masala Dosa with Chutney', price: 60.0, quantity: 1, cookingTimeMinutes: 10),
      ],
      totalAmount: 60.0,
      status: OrderStatus.ready, // Ready for pickup with OTP
      paymentStatus: 'paid',
      orderOtp: '3310',
      createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
  ];

  static final _orderStreamController = StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> streamActiveOrders(String vendorId) {
    try {
      if (_firestore != null) {
        return _firestore!
            .collection('orders')
            .where('vendorId', isEqualTo: vendorId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list.isNotEmpty ? list : _demoOrders;
        });
      }
    } catch (_) {}

    Future.microtask(() => _orderStreamController.add(List.from(_demoOrders)));
    return _orderStreamController.stream;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': newStatus.name,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return;
      }
    } catch (_) {}

    final idx = _demoOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _demoOrders[idx] = _demoOrders[idx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _orderStreamController.add(List.from(_demoOrders));
    }
  }

  Future<bool> verifyAndCompleteOrder({
    required String orderId,
    required String inputOtp,
    required String actualOtp,
  }) async {
    if (inputOtp.trim() == actualOtp.trim()) {
      await updateOrderStatus(orderId, OrderStatus.completed);
      return true;
    }
    return false;
  }

  // Simulation Helper for testing & demo
  Future<void> simulateStudentOrder({
    required String vendorId,
    required String campusId,
  }) async {
    final rng = Random();
    final studentNames = ['Aman Gupta', 'Pooja Iyer', 'Rohan Mehta', 'Kavya Nair', 'Siddharth Rao'];
    final samplePool = [
      {'itemId': 'item_1', 'name': 'Paneer Butter Masala Combo', 'price': 130.0, 'cookingTime': 15},
      {'itemId': 'item_2', 'name': 'Crispy Veg Burger', 'price': 70.0, 'cookingTime': 10},
      {'itemId': 'item_3', 'name': 'Masala Dosa', 'price': 60.0, 'cookingTime': 10},
      {'itemId': 'item_4', 'name': 'Iced Cold Coffee', 'price': 50.0, 'cookingTime': 5},
    ];

    final pickedItems = <OrderItemModel>[];
    final it = samplePool[rng.nextInt(samplePool.length)];
    pickedItems.add(
      OrderItemModel(
        itemId: it['itemId'] as String,
        name: it['name'] as String,
        price: it['price'] as double,
        quantity: rng.nextInt(2) + 1,
        cookingTimeMinutes: it['cookingTime'] as int,
      ),
    );

    final total = pickedItems.fold<double>(0.0, (acc, i) => acc + (i.price * i.quantity));
    final otp = (1000 + rng.nextInt(9000)).toString();
    final now = DateTime.now();

    final order = OrderModel(
      id: 'ORD_${rng.nextInt(9000) + 1000}',
      userId: 'student_${rng.nextInt(1000)}',
      userName: studentNames[rng.nextInt(studentNames.length)],
      userPhone: '98${rng.nextInt(90000000) + 10000000}',
      vendorId: vendorId,
      campusId: campusId,
      items: pickedItems,
      totalAmount: total,
      status: OrderStatus.placed,
      paymentStatus: 'paid',
      orderOtp: otp,
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (_firestore != null) {
        await _firestore!.collection('orders').add(order.toMap());
        return;
      }
    } catch (_) {}

    _demoOrders.insert(0, order);
    _orderStreamController.add(List.from(_demoOrders));
  }
}
