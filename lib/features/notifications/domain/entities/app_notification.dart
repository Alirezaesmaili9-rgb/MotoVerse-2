import 'package:equatable/equatable.dart';

/// Notification category — drives the leading icon/color.
enum NotificationType {
  maintenance,
  insurance,
  order,
  roadside,
  news,
  general;

  static NotificationType fromKey(String? key) => switch (key) {
        'maintenance' => NotificationType.maintenance,
        'insurance' => NotificationType.insurance,
        'order' => NotificationType.order,
        'roadside' => NotificationType.roadside,
        'news' => NotificationType.news,
        _ => NotificationType.general,
      };
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.body,
  });

  final String id;
  final String title;
  final String? body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, isRead, createdAt];
}
