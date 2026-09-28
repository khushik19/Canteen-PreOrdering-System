import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/vendor_model.dart';
import '../models/menu_item_model.dart';
import '../models/flash_sale_model.dart';

class VendorRemoteDatasource {
  FirebaseFirestore? _firestore;

  VendorRemoteDatasource({FirebaseFirestore? firestore}) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      _firestore = null;
    }
  }

  // In-memory fallback for offline/demo running
  static final List<MenuItemModel> _demoMenuItems = [
    MenuItemModel(
      id: 'demo_item_1',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      name: 'Paneer Butter Masala Combo',
      description: 'Served with 3 butter rotis, jeera rice & fresh salad',
      price: 130.0,
      category: 'Meals',
      isAvailable: true,
      cookingTimeMinutes: 15,
      isVeg: true,
      createdAt: DateTime.now(),
    ),
    MenuItemModel(
      id: 'demo_item_2',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      name: 'Crispy Veg Burger',
      description: 'Loaded with cheese, lettuce, tomato & mayo patty',
      price: 70.0,
      category: 'Snacks',
      isAvailable: true,
      cookingTimeMinutes: 10,
      isVeg: true,
      createdAt: DateTime.now(),
    ),
    MenuItemModel(
      id: 'demo_item_3',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      name: 'Masala Dosa with Chutney',
      description: 'Crispy golden dosa with potato masala & piping hot sambar',
      price: 60.0,
      category: 'Breakfast',
      isAvailable: true,
      cookingTimeMinutes: 10,
      isVeg: true,
      createdAt: DateTime.now(),
    ),
    MenuItemModel(
      id: 'demo_item_4',
      vendorId: 'vendor_demo_101',
      campusId: 'Main Campus',
      name: 'Iced Cold Coffee with Ice Cream',
      description: 'Rich creamy blend with chocolate drizzle',
      price: 50.0,
      category: 'Beverages',
      isAvailable: true,
      cookingTimeMinutes: 5,
      isVeg: true,
      createdAt: DateTime.now(),
    ),
  ];

  static final _menuStreamController = StreamController<List<MenuItemModel>>.broadcast();

  // ---------------- VENDOR PROFILE & STORE STATUS ---------------- //

  Future<VendorModel?> getVendorProfile(String vendorId) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('vendors').doc(vendorId).get();
        if (doc.exists && doc.data() != null) {
          return VendorModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (e) {
      debugPrint('Firestore fallback: $e');
    }

    return VendorModel(
      id: vendorId,
      canteenName: 'Central Campus Canteen',
      campusId: 'Main Campus',
      ownerName: 'Canteen Staff',
      email: 'vendor@campus.edu',
      phone: '9876543210',
      isOpen: true,
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveVendorProfile(VendorModel vendor) async {
    try {
      if (_firestore != null) {
        await _firestore!
            .collection('vendors')
            .doc(vendor.id)
            .set(vendor.toMap(), SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<void> toggleStoreStatus(String vendorId, bool isOpen) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('vendors').doc(vendorId).update({'isOpen': isOpen});
      }
    } catch (_) {}
  }

  // ---------------- MENU ITEMS CRUD ---------------- //

  Stream<List<MenuItemModel>> streamMenuItems(String vendorId) {
    try {
      if (_firestore != null) {
        return _firestore!
            .collection('menu_items')
            .where('vendorId', isEqualTo: vendorId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
              .toList();
          return list.isNotEmpty ? list : _demoMenuItems;
        });
      }
    } catch (_) {}

    // Emit demo menu items on stream
    Future.microtask(() => _menuStreamController.add(List.from(_demoMenuItems)));
    return _menuStreamController.stream;
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('menu_items').add(item.toMap());
        return;
      }
    } catch (_) {}

    final itemWithId = item.copyWith();
    _demoMenuItems.add(itemWithId);
    _menuStreamController.add(List.from(_demoMenuItems));
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('menu_items').doc(item.id).update(item.toMap());
        return;
      }
    } catch (_) {}

    final idx = _demoMenuItems.indexWhere((it) => it.id == item.id);
    if (idx != -1) {
      _demoMenuItems[idx] = item;
      _menuStreamController.add(List.from(_demoMenuItems));
    }
  }

  Future<void> toggleMenuItemAvailability(String itemId, bool isAvailable) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('menu_items').doc(itemId).update({
          'isAvailable': isAvailable,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return;
      }
    } catch (_) {}

    final idx = _demoMenuItems.indexWhere((it) => it.id == itemId);
    if (idx != -1) {
      _demoMenuItems[idx] = _demoMenuItems[idx].copyWith(isAvailable: isAvailable);
      _menuStreamController.add(List.from(_demoMenuItems));
    }
  }

  Future<void> updateCookingTime(String itemId, int cookingTimeMinutes) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('menu_items').doc(itemId).update({
          'cookingTimeMinutes': cookingTimeMinutes,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        return;
      }
    } catch (_) {}

    final idx = _demoMenuItems.indexWhere((it) => it.id == itemId);
    if (idx != -1) {
      _demoMenuItems[idx] = _demoMenuItems[idx].copyWith(cookingTimeMinutes: cookingTimeMinutes);
      _menuStreamController.add(List.from(_demoMenuItems));
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('menu_items').doc(itemId).delete();
        return;
      }
    } catch (_) {}

    _demoMenuItems.removeWhere((it) => it.id == itemId);
    _menuStreamController.add(List.from(_demoMenuItems));
  }

  // ---------------- FLASH SALE TRIGGER ---------------- //

  static final List<FlashSaleModel> _demoFlashSales = [
    FlashSaleModel(
      id: 'demo_flash_1',
      orderId: 'ORD_9390',
      itemId: 'item_1',
      itemName: 'Paneer Butter Masala Combo',
      originalPrice: 130.0,
      discountPercent: 40,
      campusId: 'Main Campus',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      expiresAt: DateTime.now().add(const Duration(minutes: 20)),
      status: FlashSaleStatus.active,
    ),
    FlashSaleModel(
      id: 'demo_flash_2',
      orderId: 'ORD_9385',
      itemId: 'item_2',
      itemName: 'Crispy Veg Burger',
      originalPrice: 70.0,
      discountPercent: 50,
      campusId: 'Main Campus',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      status: FlashSaleStatus.active,
    ),
  ];

  static final _flashStreamController = StreamController<List<FlashSaleModel>>.broadcast();

  Stream<List<FlashSaleModel>> streamFlashSales(String campusId) {
    try {
      if (_firestore != null) {
        return _firestore!
            .collection('flash_sales')
            .where('campusId', isEqualTo: campusId)
            .snapshots()
            .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FlashSaleModel.fromMap(doc.data(), doc.id))
              .toList();
          return list.isNotEmpty ? list : _demoFlashSales;
        });
      }
    } catch (_) {}

    Future.microtask(() => _flashStreamController.add(List.from(_demoFlashSales)));
    return _flashStreamController.stream;
  }

  Future<void> createFlashSale(FlashSaleModel flashSale) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('flash_sales').add(flashSale.toMap());
        return;
      }
    } catch (_) {}

    final sale = flashSale.id.isEmpty ? flashSale.copyWith() : flashSale;
    _demoFlashSales.insert(0, sale);
    _flashStreamController.add(List.from(_demoFlashSales));
  }

  Future<void> deleteFlashSale(String flashSaleId) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('flash_sales').doc(flashSaleId).delete();
        return;
      }
    } catch (_) {}

    _demoFlashSales.removeWhere((s) => s.id == flashSaleId);
    _flashStreamController.add(List.from(_demoFlashSales));
  }
}
