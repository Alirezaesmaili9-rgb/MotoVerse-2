import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.watch(supabaseClientProvider));
});

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  ref.watch(authStateChangesProvider);
  final res =
      await ref.watch(notificationsRepositoryProvider).getNotifications();
  return res.fold((f) => throw Exception(f.message), (n) => n);
});

/// Live unread badge count.
final unreadCountProvider = StreamProvider<int>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(notificationsRepositoryProvider).watchUnreadCount();
});

final notificationsActionsProvider =
    Provider((ref) => _NotificationActions(ref));

class _NotificationActions {
  _NotificationActions(this.ref);
  final Ref ref;

  Future<void> markRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    ref.invalidate(notificationsProvider);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    ref.invalidate(notificationsProvider);
  }
}
