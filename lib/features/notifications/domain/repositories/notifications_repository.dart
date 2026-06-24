import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  Future<Either<Failure, Unit>> markRead(String id);

  Future<Either<Failure, Unit>> markAllRead();

  /// Live unread count (Supabase realtime) for the home-screen badge.
  Stream<int> watchUnreadCount();
}
