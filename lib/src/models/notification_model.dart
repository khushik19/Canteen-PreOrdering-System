enum NotificationType { flashSale, orderStatus, general }

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload; // e.g. {'orderId': '123'} or {'flashSaleId': '456'}
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'general'),
        orElse: () => NotificationType.general,
      ),
      title: map['title'] as String,
      body: map['body'] as String,
      payload: map['payload'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'payload': payload,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      payload: payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}