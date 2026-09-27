import '../datasources/flash_sale_remote_datasource.dart';
import '../models/flash_sale_model.dart';

class FlashSaleRepository {
  final FlashSaleRemoteDatasource _datasource;

  FlashSaleRepository({FlashSaleRemoteDatasource? datasource})
      : _datasource = datasource ?? FlashSaleRemoteDatasource();

  Future<List<FlashSaleModel>> getActiveFlashSales(String campusId) {
    return _datasource.fetchActiveFlashSales(campusId);
  }

  Stream<List<FlashSaleModel>> watchActiveFlashSales(String campusId) {
    return _datasource.watchActiveFlashSales(campusId);
  }

  Future<String> createFlashSale({
    required String orderId,
    required String itemId,
    required String itemName,
    String? imageUrl,
    required double originalPrice,
    required int discountPercent,
    required String campusId,
    required Duration validFor,
  }) {
    final now = DateTime.now();
    final sale = FlashSaleModel(
      id: '', // Firestore assigns this
      orderId: orderId,
      itemId: itemId,
      itemName: itemName,
      imageUrl: imageUrl,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      campusId: campusId,
      createdAt: now,
      expiresAt: now.add(validFor),
    );
    return _datasource.createFlashSale(sale);
  }

  Future<bool> claimFlashSale(String flashSaleId, String userId) {
    return _datasource.claimFlashSale(flashSaleId, userId);
  }
}