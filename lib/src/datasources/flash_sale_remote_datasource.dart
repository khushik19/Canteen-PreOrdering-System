import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flash_sale_model.dart';

class FlashSaleRemoteDatasource {
  final FirebaseFirestore _firestore;

  FlashSaleRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('flash_sales');

  /// One-time fetch of active flash sales for a campus.
  Future<List<FlashSaleModel>> fetchActiveFlashSales(String campusId) async {
    final snapshot = await _collection
        .where('campusId', isEqualTo: campusId)
        .where('status', isEqualTo: FlashSaleStatus.active.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            FlashSaleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((sale) => !sale.isExpired) // extra client-side safety filter
        .toList();
  }

  /// Real-time stream — use this in the UI so new flash sales appear live.
  Stream<List<FlashSaleModel>> watchActiveFlashSales(String campusId) {
    return _collection
        .where('campusId', isEqualTo: campusId)
        .where('status', isEqualTo: FlashSaleStatus.active.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashSaleModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Creates a flash sale — called from the vendor side (coordinate with Person C).
  Future<String> createFlashSale(FlashSaleModel sale) async {
    final docRef = await _collection.add(sale.toMap());
    return docRef.id;
  }

  /// Claim a flash sale atomically — prevents two users claiming the same item.
  Future<bool> claimFlashSale(String flashSaleId, String userId) async {
    final docRef = _collection.doc(flashSaleId);

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      if (data['status'] != FlashSaleStatus.active.name) {
        return false; // already claimed or expired
      }

      transaction.update(docRef, {
        'status': FlashSaleStatus.claimed.name,
        'claimedByUserId': userId,
      });
      return true;
    });
  }
}