import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsActionsProvider).markAllRead(),
            child: const Text('خواندن همه'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('اعلان جدیدی نداری'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _NotificationTile(notification: list[i]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final AppNotification notification;

  ({IconData icon, Color color}) get _style => switch (notification.type) {
        NotificationType.maintenance => (
            icon: Icons.build_circle_outlined,
            color: AppColors.primary
          ),
        NotificationType.insurance => (
            icon: Icons.verified_user_outlined,
            color: AppColors.success
          ),
        NotificationType.order => (
            icon: Icons.shopping_bag_outlined,
            color: AppColors.marketplacePurple
          ),
        NotificationType.roadside => (
            icon: Icons.emergency_outlined,
            color: AppColors.danger
          ),
        NotificationType.news => (
            icon: Icons.newspaper_outlined,
            color: AppColors.cyan
          ),
        NotificationType.general => (
            icon: Icons.notifications_outlined,
            color: AppColors.textSecondary
          ),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = _style;
    final date = PersianUtils.toFa(
        intl.DateFormat('yyyy/MM/dd  HH:mm').format(notification.createdAt));

    return InkWell(
      onTap: notification.isRead
          ? null
          : () => ref
              .read(notificationsActionsProvider)
              .markRead(notification.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surface
              : AppColors.primaryLight.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: s.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.icon, color: s.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: Theme.of(context).textTheme.titleSmall),
                  if (notification.body != null) ...[
                    const SizedBox(height: 2),
                    Text(notification.body!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 4),
                  Text(date, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
