import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRemoteDatasource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('notifications');

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({'isRead': true});
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _collection.add(notification.toMap());
  }

  /// Registers/updates the current device's FCM token under the user doc.
  /// Called from notification_service.dart during Phase 3.
  Future<void> saveFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
      SetOptions(merge: true),
    );
  }
}