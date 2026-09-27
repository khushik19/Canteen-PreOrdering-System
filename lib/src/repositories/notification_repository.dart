import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final NotificationRemoteDatasource _datasource;

  NotificationRepository({NotificationRemoteDatasource? datasource})
      : _datasource = datasource ?? NotificationRemoteDatasource();

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _datasource.watchNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) {
    return _datasource.markAsRead(notificationId);
  }

  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      payload: payload,
      createdAt: DateTime.now(),
    );
    return _datasource.createNotification(notification);
  }

  Future<void> saveFcmToken(String userId, String token) {
    return _datasource.saveFcmToken(userId, token);
  }
}