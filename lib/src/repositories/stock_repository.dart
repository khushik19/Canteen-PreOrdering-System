import '../datasources/stock_remote_datasource.dart';
import '../models/stock_item_model.dart';

class StockRepository {
  final StockRemoteDatasource _remoteDatasource;

  StockRepository({StockRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? StockRemoteDatasource();

  Stream<List<StockItemModel>> streamStockItems(String vendorId) =>
      _remoteDatasource.streamStockItems(vendorId);

  Future<void> addStockItem(StockItemModel item) =>
      _remoteDatasource.addStockItem(item);

  Future<void> updateStockItem(StockItemModel item) =>
      _remoteDatasource.updateStockItem(item);

  Future<void> updateStockQuantity(String stockId, int newQuantity) =>
      _remoteDatasource.updateStockQuantity(stockId, newQuantity);

  Future<void> toggleStockAvailability(String stockId, bool isAvailable) =>
      _remoteDatasource.toggleStockAvailability(stockId, isAvailable);

  Future<void> deleteStockItem(String stockId) =>
      _remoteDatasource.deleteStockItem(stockId);
}
