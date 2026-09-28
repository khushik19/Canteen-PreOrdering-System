import '../datasources/vendor_remote_datasource.dart';
import '../datasources/vendor_order_datasource.dart';
import '../models/vendor_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/flash_sale_model.dart';

class VendorRepository {
  final VendorRemoteDatasource _remoteDatasource;
  final VendorOrderDatasource _orderDatasource;

  VendorRepository({
    VendorRemoteDatasource? remoteDatasource,
    VendorOrderDatasource? orderDatasource,
  })  : _remoteDatasource = remoteDatasource ?? VendorRemoteDatasource(),
        _orderDatasource = orderDatasource ?? VendorOrderDatasource();

  // Vendor Profile & Status
  Future<VendorModel?> getVendorProfile(String vendorId) =>
      _remoteDatasource.getVendorProfile(vendorId);

  Future<void> saveVendorProfile(VendorModel vendor) =>
      _remoteDatasource.saveVendorProfile(vendor);

  Future<void> toggleStoreStatus(String vendorId, bool isOpen) =>
      _remoteDatasource.toggleStoreStatus(vendorId, isOpen);

  // Menu Management
  Stream<List<MenuItemModel>> streamMenuItems(String vendorId) =>
      _remoteDatasource.streamMenuItems(vendorId);

  Future<void> addMenuItem(MenuItemModel item) =>
      _remoteDatasource.addMenuItem(item);

  Future<void> updateMenuItem(MenuItemModel item) =>
      _remoteDatasource.updateMenuItem(item);

  Future<void> toggleMenuItemAvailability(String itemId, bool isAvailable) =>
      _remoteDatasource.toggleMenuItemAvailability(itemId, isAvailable);

  Future<void> updateCookingTime(String itemId, int cookingTimeMinutes) =>
      _remoteDatasource.updateCookingTime(itemId, cookingTimeMinutes);

  Future<void> deleteMenuItem(String itemId) =>
      _remoteDatasource.deleteMenuItem(itemId);

  // Orders Live Pipeline
  Stream<List<OrderModel>> streamActiveOrders(String vendorId) =>
      _orderDatasource.streamActiveOrders(vendorId);

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) =>
      _orderDatasource.updateOrderStatus(orderId, newStatus);

  Future<bool> verifyAndCompleteOrder({
    required String orderId,
    required String inputOtp,
    required String actualOtp,
  }) =>
      _orderDatasource.verifyAndCompleteOrder(
        orderId: orderId,
        inputOtp: inputOtp,
        actualOtp: actualOtp,
      );

  // Simulation Helper for testing & demo
  Future<void> simulateStudentOrder({
    required String vendorId,
    required String campusId,
  }) =>
      _orderDatasource.simulateStudentOrder(
        vendorId: vendorId,
        campusId: campusId,
      );

  // Flash Sale integration
  Stream<List<FlashSaleModel>> streamFlashSales(String campusId) =>
      _remoteDatasource.streamFlashSales(campusId);

  Future<void> createFlashSale(FlashSaleModel flashSale) =>
      _remoteDatasource.createFlashSale(flashSale);

  Future<void> deleteFlashSale(String flashSaleId) =>
      _remoteDatasource.deleteFlashSale(flashSaleId);
}
