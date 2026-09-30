import 'package:flutter/material.dart';
import '../../models/flash_sale_model.dart';
import '../../repositories/flash_sale_repository.dart';

enum FlashSaleLoadState { loading, loaded, error }

class FlashSaleController extends ChangeNotifier {
  final FlashSaleRepository _repository;

  FlashSaleController({FlashSaleRepository? repository})
      : _repository = repository ?? FlashSaleRepository();

  FlashSaleLoadState _state = FlashSaleLoadState.loading;
  FlashSaleLoadState get state => _state;

  List<FlashSaleModel> _sales = [];
  List<FlashSaleModel> get sales => _sales;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _claimingId;
  String? get claimingId => _claimingId;

  void watchCampus(String campusId) {
    _state = FlashSaleLoadState.loading;
    notifyListeners();

    _repository.watchActiveFlashSales(campusId).listen(
      (sales) {
        _sales = sales;
        _state = FlashSaleLoadState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = FlashSaleLoadState.error;
        notifyListeners();
      },
    );
  }

  Future<bool> claim(String flashSaleId, String userId) async {
    _claimingId = flashSaleId;
    notifyListeners();
    try {
      return await _repository.claimFlashSale(flashSaleId, userId);
    } finally {
      _claimingId = null;
      notifyListeners();
    }
  }
}