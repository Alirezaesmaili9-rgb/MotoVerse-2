import '../../domain/entities/app_notification.dart';

class AppNotificationModel {
  const AppNotificationModel._();

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      type: NotificationType.fromKey(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
