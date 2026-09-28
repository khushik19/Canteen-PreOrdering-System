import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_item_model.dart';

class StockRemoteDatasource {
  FirebaseFirestore? _firestore;

  StockRemoteDatasource({FirebaseFirestore? firestore}) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      _firestore = null;
    }
  }

  static final List<StockItemModel> _demoStockItems = [
    StockItemModel(
      id: 'demo_stock_1',
      vendorId: 'vendor_demo_101',
      name: 'Lays Classic Salted 50g',
      category: 'Packaged Snacks',
      price: 20.0,
      quantity: 28,
      lowStockThreshold: 8,
      isAvailable: true,
      updatedAt: DateTime.now(),
    ),
    StockItemModel(
      id: 'demo_stock_2',
      vendorId: 'vendor_demo_101',
      name: 'Coca-Cola Can 300ml',
      category: 'Cold Beverages',
      price: 40.0,
      quantity: 15,
      lowStockThreshold: 5,
      isAvailable: true,
      updatedAt: DateTime.now(),
    ),
    StockItemModel(
      id: 'demo_stock_3',
      vendorId: 'vendor_demo_101',
      name: 'Cadbury Dairy Milk Silk 60g',
      category: 'Chocolates & Candies',
      price: 80.0,
      quantity: 4, // Trigger low stock!
      lowStockThreshold: 6,
      isAvailable: true,
      updatedAt: DateTime.now(),
    ),
    StockItemModel(
      id: 'demo_stock_4',
      vendorId: 'vendor_demo_101',
      name: 'Red Bull Energy Drink 250ml',
      category: 'Cold Beverages',
      price: 125.0,
      quantity: 12,
      lowStockThreshold: 4,
      isAvailable: true,
      updatedAt: DateTime.now(),
    ),
    StockItemModel(
      id: 'demo_stock_5',
      vendorId: 'vendor_demo_101',
      name: 'Oreo Vanilla Cream 120g',
      category: 'Bakery & Biscuits',
      price: 35.0,
      quantity: 0, // Out of stock!
      lowStockThreshold: 5,
      isAvailable: false,
      updatedAt: DateTime.now(),
    ),
  ];

  static final _stockStreamController = StreamController<List<StockItemModel>>.broadcast();

  Stream<List<StockItemModel>> streamStockItems(String vendorId) {
    try {
      if (_firestore != null) {
        return _firestore!
            .collection('stock_items')
            .where('vendorId', isEqualTo: vendorId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => StockItemModel.fromMap(doc.data(), doc.id))
              .toList();
          return list.isNotEmpty ? list : _demoStockItems;
        });
      }
    } catch (_) {}

    Future.microtask(() => _stockStreamController.add(List.from(_demoStockItems)));
    return _stockStreamController.stream;
  }

  Future<void> addStockItem(StockItemModel item) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('stock_items').add(item.toMap());
        return;
      }
    } catch (_) {}

    _demoStockItems.add(item);
    _stockStreamController.add(List.from(_demoStockItems));
  }

  Future<void> updateStockItem(StockItemModel item) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('stock_items').doc(item.id).update(item.toMap());
        return;
      }
    } catch (_) {}

    final idx = _demoStockItems.indexWhere((it) => it.id == item.id);
    if (idx != -1) {
      _demoStockItems[idx] = item;
      _stockStreamController.add(List.from(_demoStockItems));
    }
  }

  Future<void> updateStockQuantity(String stockId, int newQuantity) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('stock_items').doc(stockId).update({
          'quantity': newQuantity,
          'isAvailable': newQuantity > 0,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return;
      }
    } catch (_) {}

    final idx = _demoStockItems.indexWhere((it) => it.id == stockId);
    if (idx != -1) {
      _demoStockItems[idx] = _demoStockItems[idx].copyWith(
        quantity: newQuantity,
        isAvailable: newQuantity > 0,
        updatedAt: DateTime.now(),
      );
      _stockStreamController.add(List.from(_demoStockItems));
    }
  }

  Future<void> toggleStockAvailability(String stockId, bool isAvailable) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('stock_items').doc(stockId).update({
          'isAvailable': isAvailable,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return;
      }
    } catch (_) {}

    final idx = _demoStockItems.indexWhere((it) => it.id == stockId);
    if (idx != -1) {
      _demoStockItems[idx] = _demoStockItems[idx].copyWith(
        isAvailable: isAvailable,
        updatedAt: DateTime.now(),
      );
      _stockStreamController.add(List.from(_demoStockItems));
    }
  }

  Future<void> deleteStockItem(String stockId) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('stock_items').doc(stockId).delete();
        return;
      }
    } catch (_) {}

    _demoStockItems.removeWhere((it) => it.id == stockId);
    _stockStreamController.add(List.from(_demoStockItems));
  }
}
