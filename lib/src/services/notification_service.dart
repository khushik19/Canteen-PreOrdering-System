import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../repositories/notification_repository.dart';

/// Must be a top-level function (not a class method) â€” this is how FCM
/// requires background handlers to be defined.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Keep this minimal â€” heavy work here can be killed by the OS.
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationRepository _notificationRepository;

  /// Called when the user taps a notification (foreground or background).
  /// Wire this up in your app's navigation layer to deep-link correctly.
  void Function(Map<String, dynamic> payload)? onNotificationTap;

  NotificationService({NotificationRepository? notificationRepository})
      : _notificationRepository =
            notificationRepository ?? NotificationRepository();

  /// Call this once, early in app startup (after Firebase.initializeApp).
  Future<void> initialize({required String userId}) async {
    await _requestPermissions();
    await _setupLocalNotifications();
    await _registerToken(userId);
    _listenForTokenRefresh(userId);
    _listenForForegroundMessages();
    _listenForNotificationTaps();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return; // flutter_local_notifications does not support web
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> _registerToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _notificationRepository.saveFcmToken(userId, token);
      debugPrint('FCM token registered for user $userId');
    }
  }

  void _listenForTokenRefresh(String userId) {
    _messaging.onTokenRefresh.listen((newToken) {
      _notificationRepository.saveFcmToken(userId, newToken);
    });
  }

  /// Shows a local banner when a push arrives while the app is open
  /// FCM does not display foreground notifications automatically.
  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'canteen_crave_channel',
              'Canteen Crave Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  /// Handles taps on notifications that opened the app from background/terminated.
  void _listenForNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onNotificationTap?.call(message.data);
    });

    // Handles the case where the app was fully closed and opened via notification tap.
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        onNotificationTap?.call(message.data);
      }
    });
  }
}
